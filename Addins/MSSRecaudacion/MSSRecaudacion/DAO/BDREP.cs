using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Reflection;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Xml;
using Microsoft.Dexterity.Applications;

namespace MSSRecaudacion.DAO
{
    public class BDREP
    {
        #region Variables
        private SqlParameter _Parametro = null;
        private SqlConnection _Conexion = null;
        private SqlCommand _Comando = null;
        private SqlDataAdapter _Adaptador = null;
        private SqlDataReader _Reader = null;
        private SqlTransaction _Transaccion = null;
        private string _CadenaConexion;
        private string _MensajeError;
        private Exception _MensajeErrorReal;

        public Exception MensajeErrorReal
        {
            get { return _MensajeErrorReal; }
            set { _MensajeErrorReal = value; }
        }
        private static BDREP mInstance;
        private static System.Threading.Mutex mMutex = new System.Threading.Mutex();
        //private static string _Server;
        //private static string _Database;
        private static string _User;
        private static string _Password;
        #endregion

        #region Propiedad
        private static string Server()
        {
            Microsoft.Dexterity.Applications.DynamicsDictionary.SyBackupRestoreForm backup;
            backup = Microsoft.Dexterity.Applications.Dynamics.Forms.SyBackupRestore;
            return backup.Functions.GetServerNameWithInstance.Invoke();
           // return "Daniel-NoteBook";
        }
        private static string Database()
        {
            //return Dynamics.Globals.IntercompanyId.Value;
            return "REPCOVI";
        }
       
        #endregion

        #region "Crear, Destruir, Configurar y Conectar"
        private BDREP()
        {
            Seguridad enc = new Seguridad();
            string directory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            string file = Path.Combine(directory, "Data.dat");
            using (XmlTextReader reader = new XmlTextReader(file))
            {
                reader.MoveToContent();
                reader.ReadStartElement();
                while (reader.Read())
                    if (reader.NodeType == XmlNodeType.Element)
                        switch (reader.Name)
                        {
                            case "uid": _User = enc.Desencriptar(reader.ReadString()); break;
                            case "pwd": _Password = enc.Desencriptar(reader.ReadString()); break;
                        }
                reader.Close();
            }
            //_User = "sa";
            //_Password = "Vws2008r2";
        }

        /// <summary>
        /// Crea una instancia de esta clase.
        /// </summary>
        public static BDREP GetInstance()
        {
            //mMutex.WaitOne();
            //if (mInstance == null)
            //{
                mInstance = new BDREP();
                mInstance.Configurar();
            //}
            //mMutex.ReleaseMutex();
            return mInstance;
        }

        /// <summary>
        /// Configura el acceso a la base de datos para su utilización.
        /// </summary>
        /// <remarks></remarks>
        private void Configurar()
        {
            try
            {
                this._CadenaConexion = "data source=" + Server() + ";database=" + Database() + ";uid=" + _User + ";pwd=" + _Password + ";";
            }
            catch (ConfigurationException ex)
            {
                _MensajeError = "Error al cargar la configuración del acceso a datos.";
                _MensajeErrorReal = ex;
            }
        }

        /// <summary>
        /// Se concecta con la base de datos.
        /// </summary>
        /// <remarks></remarks>
        private void Conectar()
        {
            try
            {
                if (this._Conexion == null)
                {
                    this._Conexion = new SqlConnection();
                    this._Conexion.ConnectionString = _CadenaConexion;
                }
                this._Conexion.Close();
                this._Conexion.Open();
            }
            catch (DataException ex)
            {
                _MensajeError = "Error al conectarse.";
                _MensajeErrorReal = ex;
            }
        }
        #endregion

        #region "Retorno de Errores"
        /// <summary>
        /// Retorna un mensaje de error ocurrido y definido por el programador
        /// </summary>
        /// <returns></returns>
        /// <remarks></remarks>
        public string getError()
        {
            return _MensajeError;
        }

        /// <summary>
        /// Retorna un mensaje de error ocurrido, este mensaje es el error real
        /// </summary>
        /// <returns></returns>
        /// <remarks></remarks>
        public Exception getErrorReal()
        {
            return _MensajeErrorReal;
        }
        #endregion

        #region "Transaccion"
        public int IniciarTransaccion()
        {
            int Resp = 0;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                _Transaccion = _Conexion.BeginTransaction();
                Resp = 1;
            }
            catch (SqlException ex)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al iniciar la Transacción.";
                _MensajeErrorReal = ex;
            }
            return Resp;
        }
        public int FinalizarTransaccion()
        {
            int Resp = 0;
            try
            {
                _Transaccion.Commit();
                Resp = 1;
            }
            catch (SqlException ex)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al finalizar la Transacción.";
                _MensajeErrorReal = ex;
            }
            finally
            {
                _Conexion.Close();
                _Transaccion = null;
            }
            return Resp;
        }
        #endregion

        #region "Creacion de Variables para los Procesos"
        private IDbCommand CrearComando(int Tipo, string ComandoTexto, object[] Argumentos)
        {
            _Comando = null;
            _Comando = new SqlCommand();
            _Comando.Connection = _Conexion;
            _Comando.CommandTimeout = 100000;
            if ((_Transaccion != null))
                _Comando.Transaction = _Transaccion;
            switch (Tipo)
            {
                case 1:
                    _Comando.CommandType = CommandType.Text;
                    _Comando.CommandText = ComandoTexto;
                    break;
                case 2:
                    _Comando.CommandType = CommandType.StoredProcedure;
                    _Comando.CommandText = ComandoTexto;
                    SqlCommandBuilder.DeriveParameters(_Comando);
                    break;
                case 3:
                    this._Comando.CommandType = CommandType.TableDirect;
                    break;
            }
            if ((Argumentos != null))
                CargarParametros(Argumentos);
            return _Comando;
        }
        private void CrearAdaptadorConsultas(int Tipo, string ComandoTexto, object[] Argumentos)
        {
            CrearComando(Tipo, ComandoTexto, Argumentos);
            _Adaptador = null;
            _Adaptador = new SqlDataAdapter();
            _Adaptador.SelectCommand = _Comando;
        }
        private void CargarParametros(object[] Argumentos)
        {
            {
                for (int i = 0; i <= Argumentos.Length - 1; i++)
                {
                    _Parametro = _Comando.Parameters[i + 1];
                    if (_Parametro.Direction == ParameterDirection.Input | _Parametro.Direction == ParameterDirection.InputOutput)
                    {
                        _Parametro.Value = Argumentos[i];
                    }
                }
            }
        }
        private void RetornarParametros(ref ArrayList ArgDev, object[] Argumentos)
        {
            {
                for (int i = 0; i <= Argumentos.Length - 1; i++)
                {
                    _Parametro = _Comando.Parameters[i + 1];
                    if (_Parametro.Direction == ParameterDirection.Output | _Parametro.Direction == ParameterDirection.InputOutput)
                    {
                        _Parametro.Direction = ParameterDirection.Output;
                    }
                    ArgDev.Add(_Parametro.Value);
                }
            }
        }
        #endregion

        #region "Funciones para Ejecutar Procedimientos"
        public int Ejecute(string ProcedimientoAlmacenado, params object[] Argumentos)
        {
            int Resp = 0;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                Resp = CrearComando(2, ProcedimientoAlmacenado, Argumentos).ExecuteNonQuery();
            }
            catch (SqlException ex1)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
            }
            catch (Exception ex2)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
            }
            finally
            {
                _Conexion.Close();
            }
            return Resp;
        }
        public int Ejecute(string ProcedimientoAlmacenado, ref ArrayList ArgDev, params object[] Argumentos)
        {
            int Resp = 0;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                Resp = CrearComando(2, ProcedimientoAlmacenado, Argumentos).ExecuteNonQuery();
                RetornarParametros(ref ArgDev, Argumentos);
            }
            catch (SqlException ex1)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
            }
            catch (Exception ex2)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
            }
            finally
            {
                _Conexion.Close();
            }
            return Resp;
        }
        public int EjecuteSql(string consulta, ref ArrayList ArgDev, params object[] Argumentos)
        {
            int Resp = 0;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                Resp = CrearComando(1, consulta, Argumentos).ExecuteNonQuery();
                RetornarParametros(ref ArgDev, Argumentos);
            }
            catch (SqlException ex1)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el proceso.";
                _MensajeErrorReal = ex1;
            }
            catch (Exception ex2)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el proceso.";
                _MensajeErrorReal = ex2;
            }
            finally
            {
                _Conexion.Close();
            }
            return Resp;
        }
        public int EjecuteSql(string consulta, params object[] Argumentos)
        {
            int Resp = 0;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                Resp = CrearComando(1, consulta, Argumentos).ExecuteNonQuery();
            }
            catch (SqlException ex1)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el proceso.";
                _MensajeErrorReal = ex1;
            }
            catch (Exception ex2)
            {
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el proceso.";
                _MensajeErrorReal = ex2;
            }
            finally
            {
                _Conexion.Close();
            }
            return Resp;
        }
        public int EjecuteTrans(string ProcedimientoAlmacenado, ref ArrayList ArgDev, params object[] Argumentos)
        {
            int Resp = 0;
            try
            {
                Resp = CrearComando(2, ProcedimientoAlmacenado, Argumentos).ExecuteNonQuery();
                RetornarParametros(ref ArgDev, Argumentos);
            }
            catch (SqlException ex1)
            {
                _Transaccion.Rollback();
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
                _Conexion.Close();
                _Transaccion = null;
            }
            catch (Exception ex2)
            {
                _Transaccion.Rollback();
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
                _Conexion.Close();
                _Transaccion = null;
            }
            return Resp;
        }
        public int EjecuteTrans(string ProcedimientoAlmacenado, params object[] Argumentos)
        {
            int Resp = 0;
            try
            {
                Resp = CrearComando(2, ProcedimientoAlmacenado, Argumentos).ExecuteNonQuery();
            }
            catch (SqlException ex1)
            {
                _Transaccion.Rollback();
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
                _Conexion.Close();
                _Transaccion = null;
            }
            catch (Exception ex2)
            {
                _Transaccion.Rollback();
                Resp = -2;
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
                _Conexion.Close();
                _Transaccion = null;
            }
            return Resp;
        }
        #endregion

        #region "Data"
        public DataTable CargarDataTableSQL(string Consulta, string NombreTabla)
        {
            DataTable dt = new DataTable();
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                CrearAdaptadorConsultas(1, Consulta, null);
                _Adaptador.Fill(dt);
                dt.TableName = NombreTabla;
            }
            catch (SqlException ex1)
            {
                _MensajeError = "Ocurrio un error al ejecutar la consulta.";
                _MensajeErrorReal = ex1;
                return null;
            }
            catch (Exception ex2)
            {
                _MensajeError = "Ocurrio un error al ejecutar la consulta.";
                _MensajeErrorReal = ex2;
                return null;
            }
            finally
            {
                _Conexion.Close();
                _Adaptador = null;
            }
            return dt;
        }
        public DataTable CargarDataTableProc(string ProcedimientoAlmacenado, params object[] Argumentos)
        {
            DataTable dt = new DataTable();
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                CrearAdaptadorConsultas(2, ProcedimientoAlmacenado, Argumentos);
                _Adaptador.Fill(dt);
                dt.TableName = ProcedimientoAlmacenado;
            }
            catch (SqlException ex1)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
                return null;
            }
            catch (Exception ex2)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
                return null;
            }
            finally
            {
                _Conexion.Close();
                _Adaptador = null;
            }
            return dt;
        }
        public DataSet CargarDataSetProc(string ProcedimientoAlmacenado, params object[] Argumentos)
        {
            DataSet ds = new DataSet();
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                CrearAdaptadorConsultas(2, ProcedimientoAlmacenado, Argumentos);
                _Adaptador.Fill(ds, ProcedimientoAlmacenado);
            }
            catch (SqlException ex1)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
                return null;
            }
            catch (Exception ex2)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
                return null;
            }
            finally
            {
                _Conexion.Close();
                _Adaptador = null;
            }
            return ds;
        }
        public IDataReader CargarDataReaderProc(string ProcedimientoAlmacenado, params System.Object[] Argumentos)
        {
            _Reader = null;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                _Reader = (SqlDataReader)CrearComando(2, ProcedimientoAlmacenado, Argumentos).ExecuteReader(CommandBehavior.CloseConnection);
            }
            catch (SqlException ex1)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
                return null;
            }
            catch (Exception ex2)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
                return null;
            }
            finally
            {
                //_Conexion.Close()
            }
            return _Reader;
        }

        public object ObtenerEscalarProc(string ProcedimientoAlmacenado, params object[] Argumentos)
        {
            object resp = null;
            try
            {
                Conectar();
                //Crear y abrir la coneccion
                resp = CrearComando(2, ProcedimientoAlmacenado, Argumentos).ExecuteScalar();
            }
            catch (SqlException ex1)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex1;
                return null;
            }
            catch (Exception ex2)
            {
                _MensajeError = "Ocurrio un error al ejecutar el procedimiento " + ProcedimientoAlmacenado + ".";
                _MensajeErrorReal = ex2;
                return null;
            }
            finally
            {
                _Conexion.Close();
            }
            return resp;
        }
        #endregion
    }
}
