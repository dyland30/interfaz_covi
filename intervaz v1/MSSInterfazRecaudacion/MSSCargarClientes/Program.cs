using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using MSSCargarClientes.BE;
using MSSCargarClientes.BL;

namespace MSSCargarClientes
{
    class Program
    {
   
        static void Main(string[] args)
        {
            try {
                // parametros para pruebas doc CHIL 412 22/12/2011 01

                // leer argumento 1
                if (args.Count() > 0 && args[0] != null)
                {
                    // primer argumento si es cli, se ejecutara la carga de clientes
                    // si es doc se ejecutara la carga de documentos de venta
                    if (args[0].ToString().Equals("cli"))
                    {
                        //Console.WriteLine(args[0]);
                        // obtener argumento y ejecutar econnect
                        // el args[1] -> idUsuario GP
                        List<ClienteBE> clientes = ClienteBL.obtenerClientesNuevos();
                        if (clientes.Count > 0)
                        {
                            string mensaje = ManejadorEconnect.enviarClientesGP(clientes, args[0].ToString());
                            Console.WriteLine(mensaje);
                        }
                        else {
                            Console.WriteLine("No hay datos para procesar");
                        }

                       // Console.WriteLine("Se inicia proceso de envio de clientes a GP " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
                        //Console.WriteLine("Finaliza envio de clientes " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
                    }
                    else if (args[0].ToString().ToLower().Equals("doc") && args[1] != null && args[2] != null && args[3] != null)
                    {

                        //solicitar parametros para realizar la búsqueda
                        string codEstacion = args[1].ToString();
                        string stringfecha = args[2].ToString(); // la fecha debe llegar en el formato dd/MM/yyyy
                        string turno = args[3].ToString();
                        // crear array de turnos
                        List<EstacionesBE> listaEstaciones = new List<EstacionesBE>();
                        List<EstacionTurno> estacionesTurno = new List<EstacionTurno>();

                        // obtener estaciones de peaje

                        if (codEstacion.Trim().ToUpper().Equals("TODOS"))
                        {
                            listaEstaciones = EstacionesBL.obtenerEstacionesPeaje();

                        }
                        else {
                            EstacionesBE estBE = new EstacionesBE();
                            estBE.LOCNCODE = codEstacion;
                            estBE.LOCNDSCR = codEstacion;
                            listaEstaciones.Add(estBE);
                        }

                        if (listaEstaciones.Count > 0)
                        {
                            foreach (EstacionesBE est in listaEstaciones)
                            {
                                if (turno.Trim().ToUpper().Equals("TODOS"))
                                {
                                    EstacionTurno et = new EstacionTurno();
                                    et.IdEstacion = est.LOCNCODE;
                                    et.Turno = "01";

                                    estacionesTurno.Add(et);

                                    EstacionTurno et1 = new EstacionTurno();
                                    et1.IdEstacion = est.LOCNCODE;
                                    et1.Turno = "02";
                                    estacionesTurno.Add(et1);

                                    EstacionTurno et2 = new EstacionTurno();
                                    et2.IdEstacion = est.LOCNCODE;
                                    et2.Turno = "03";
                                    estacionesTurno.Add(et2);
                                }
                                else
                                {
                                    EstacionTurno et = new EstacionTurno();
                                    et.IdEstacion = est.LOCNCODE;
                                    et.Turno = turno;
                                    estacionesTurno.Add(et);
                                }

                            }
                        }

                        DateTime fecha = DateTime.ParseExact(stringfecha, "dd/MM/yyyy", CultureInfo.InvariantCulture);

                        foreach(EstacionTurno etur in estacionesTurno){

                            string nroLote = etur.IdEstacion.PadRight(4).Substring(0, 4).ToUpper() + fecha.Day.ToString().PadLeft(2, '0')
                            + fecha.Month.ToString().PadLeft(2, '0') + fecha.Year.ToString();

                            // obtener cabeceras de Documentos
                            // llamar a manejador econnect para enviar documentos a GP
                            List<CabeceraVentaBE> documentos = CabeceraVentaBL.obtenerCabecerasDocumento(etur.IdEstacion, fecha, etur.Turno);

                            if (documentos.Count > 0)
                            {
                                String mensaje = "ESTACION: " + etur.IdEstacion + " TURNO: " + etur.Turno + " \n";
                                mensaje = mensaje + ManejadorEconnect.enviarDocumentosVentaGP(documentos, nroLote, etur.IdEstacion, etur.Turno);
                                Console.WriteLine(mensaje);
                            }
                            else
                            {
                                Console.WriteLine("ESTACION: " + etur.IdEstacion + " TURNO: " + etur.Turno + " \n" + "No hay datos para procesar");
                                // insertar resumen
                                ResumenBE resumen = new ResumenBE();
                                resumen.CodEstacion = etur.IdEstacion;
                                resumen.SerieCaseta = "";
                                resumen.Turno = etur.Turno;
                                resumen.Errores = 0;
                                resumen.Procesados = 0;
                                resumen.Lote = nroLote;
                                ResumenBL.InsertarResumen(resumen);
                            }
                        
                        }
                    }

                }
                else
                {

                    Console.WriteLine("No hay argumentos");
                }
 
            } catch(Exception ex){
                Console.WriteLine(ex.Message +" " + ex.StackTrace);                  
            }
            
        }
    }
}
