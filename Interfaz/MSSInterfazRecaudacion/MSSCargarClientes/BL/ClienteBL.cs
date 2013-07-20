using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;
using System.Data;
using System.Configuration;
namespace MSSCargarClientes.BL
{
    public static class ClienteBL
    {
        public static List<ClienteBE> obtenerClientesNuevos()
        {
           // DataTable tabla = BDREP.GetInstance().CargarDataTableProc("obtenerClientesNuevos");
            List<ClienteBE> clientes = new List<ClienteBE>();

            IDataReader reader = BDREP.GetInstance().CargarDataReaderProc("obtenerClientesNuevos");
            clientes = Util.ConvertirAEntidades<ClienteBE>(reader);

            return clientes;
        }
        public static ClienteBE obtenerClienteporID(string idCliente)
        {
            IDataReader reader = BDREP.GetInstance().CargarDataReaderProc("obtenerRepCliente", idCliente);

            ClienteBE cli = null;
            List<ClienteBE> ls = Util.ConvertirAEntidades<ClienteBE>(reader);
            if(ls!=null && ls.Count>0){
                cli = ls.First<ClienteBE>();
            
            }
            
            return cli;
        }
        public static bool existeClienteGP(string idCliente) {
            DataTable tabla = BDGP.GetInstance().CargarDataTableProc("validarExistenciaCliente",idCliente);
             Nullable<Int32> numClientes = tabla.Rows[0].Field<Nullable<Int32>>(0);
            if(numClientes!=null){

                if(numClientes.Value>0){
                    return true;
                }
            
            }
            return false;
        }

        public static void modificarEstadoCliente(string idCliente, string estado, string observacion) {
            try {

                int resp = BDREP.GetInstance().Ejecute("modificarClienteRep", idCliente, estado, observacion);
                if (resp == -2)
                {
                    throw BDREP.GetInstance().MensajeErrorReal;
                }

            }catch(DataException ex){
                throw ex;
            }
        }

        public static void insertarClienteGP(ClienteBE cli,string userId) {
            int resp = 0;
            try
            {
                // transformar datos
                cli.IdVendedor = cli.IdVendedor == String.Empty || cli.IdVendedor == null ? "" : cli.IdVendedor;
                cli.Nombre1 = cli.Nombre1 == String.Empty || cli.Nombre1 == null ? "" : cli.Nombre1;
                cli.Nombre2 = cli.Nombre2 == String.Empty || cli.Nombre2 == null? "" : cli.Nombre2;
                cli.ApePaterno = cli.ApePaterno == String.Empty || cli.ApePaterno == null ? "" : cli.ApePaterno;
                cli.ApeMaterno = cli.ApeMaterno == String.Empty || cli.ApeMaterno == null ? "" : cli.ApeMaterno;
                cli.CondNivelPrecio = cli.CondNivelPrecio == String.Empty || cli.CondNivelPrecio == null ? "" : cli.CondNivelPrecio;
                cli.TipoDocumento = cli.TipoDocumento == String.Empty || cli.TipoDocumento == null ? "" : cli.TipoDocumento;

                // verificar tipo de persona
              if (cli.Tipopersona == 1)
              {
                  
                  resp = BDGP.GetInstance().Ejecute("InterfazCovi_InsertaClienteLOC",
                      cli.NomCliente,
                      cli.IdCliente,
                  cli.Nombre1, cli.Nombre2, cli.ApePaterno, cli.ApeMaterno, cli.IdCliente, cli.Tipopersona,
                  cli.TipoDocumento,"", userId, cli.IdVendedor, cli.CondNivelPrecio, "", "");

              }
              if (cli.Tipopersona == 2 || cli.Tipopersona == 3 || cli.Tipopersona == 4)
              { 
              // persona juridica
                  resp = BDGP.GetInstance().Ejecute("InterfazCovi_InsertaClienteLOC",
                      cli.NomCliente,
                      cli.IdCliente,
                  "", "", "", "", cli.IdCliente, cli.Tipopersona,
                  cli.TipoDocumento, cli.NomCliente, userId, cli.IdVendedor, cli.CondNivelPrecio, "", "");              
              }

              if (resp == -2) {
                  throw BDGP.GetInstance().MensajeErrorReal;
              }

            }
            catch (DataException ex) {

                throw ex;
            
            }

        }

        /*
        public static ClienteBE poblarObjetoCliente(DataRow fila) {
            ClienteBE cli = new ClienteBE();
            cli.IdCliente = fila.Field<String>("IdCliente");
            cli.NomCliente = fila.Field<String>("NomCliente");
            cli.NombreCorto = fila.Field<String>("NombreCorto");
            cli.Direccion = fila.Field<String>("Direccion");
            cli.Tipopersona = fila.Field<Nullable<short>>("Tipopersona");
            cli.TipoDocumento = fila.Field<String>("TipoDocumento");
            cli.Nombre1 = fila.Field<String>("Nombre1");
            cli.Nombre2 = fila.Field<String>("Nombre2");
            cli.ApePaterno = fila.Field<String>("ApePaterno");
            cli.ApeMaterno = fila.Field<String>("ApeMaterno");
            cli.IdClase = fila.Field<String>("IdClase");
            cli.IdVendedor = fila.Field<String>("IdVendedor");
            cli.IdCondicionPago = fila.Field<String>("IdCondicionPago");
            cli.Prioridad = fila.Field<Nullable<Int32>>("Prioridad");
            cli.CondNivelPrecio = fila.Field<String>("CondNivelPrecio");
            cli.Estado = fila.Field<String>("Estado");
            cli.Observacion = fila.Field<String>("Observacion");
            return cli;
        }
        */

   }
}
