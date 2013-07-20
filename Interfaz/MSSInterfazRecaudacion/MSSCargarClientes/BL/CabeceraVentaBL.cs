using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;
using System.Data;
using System.Data.SqlClient;

namespace MSSCargarClientes.BL
{
   public  class CabeceraVentaBL
    {
        // List<obtenerCabecerasFacturasResult> documentos = db.obtenerCabecerasFacturas(codEstacion, serieCaseta, fecha, turno).ToList<obtenerCabecerasFacturasResult>();
       public static List<CabeceraVentaBE> obtenerCabecerasDocumento(string codEstacion, DateTime fecha, string turno) 
        {
           
            List<CabeceraVentaBE> ls = new List<CabeceraVentaBE>();
            try {

                IDataReader reader = BDREP.GetInstance().CargarDataReaderProc("obtenerCabecerasFacturas", codEstacion, fecha, turno);
                if (reader != null)
                {
                    ls = Util.ConvertirAEntidades<CabeceraVentaBE>(reader);
                }
            
            }catch(Exception ex){
                throw ex;
            }
            return ls;
       }


       public static void crearDistribucionesCliente(CabeceraVentaBE cabecera){
           int resp = BDGP.GetInstance().Ejecute("InsertarDistribucionClienteSOP", cabecera.IdCliente.Trim(), cabecera.NroDoc.Trim());
           if (resp==-2){
               throw BDGP.GetInstance().MensajeErrorReal;

           }
       }


       public static void crearDistribucionesSOPRM(int jrentry, Int16 nroTipoDistribucion)
       {
           int resp = BDGP.GetInstance().Ejecute("InsertarAC_Financiero_SOP_RM", jrentry,nroTipoDistribucion);
           if (resp == -2)
           {
               throw BDGP.GetInstance().MensajeErrorReal;

           }
       }

       public static void InsertarValoresDefinidosUsuario(Int16 soptype, string nroDoc, DateTime fecproc, string def1, string def2, 
                                                            string def3, string def4, string def5)
       {
           int resp = BDGP.GetInstance().Ejecute("InsertarValoresDefinidosUsuarioSOP", soptype, nroDoc,fecproc, def1, def2, def3, def4, def5);
           if (resp == -2)
           {
               throw BDGP.GetInstance().MensajeErrorReal;

           }
       }


       public static void InsertarAdicionalesConsumos(string idVentana, string jrentry, int nroCampo, string  valor)
       {
           int resp = BDGP.GetInstance().Ejecute("InsertarAdicionalesConsumos", idVentana, jrentry,nroCampo, valor);
           if (resp == -2)
           {
               throw BDGP.GetInstance().MensajeErrorReal;

           }
       }


       public static void InsertarFechaProcesoVentanaPago(string idVentana, string SopNumber,string numPago, int nroCampo, DateTime valor)
       {
         
           string cod = numPago + SopNumber;

           int resp = BDGP.GetInstance().Ejecute("INSERTAR_EXTENDER_FECHA", idVentana, cod, nroCampo, valor);
           if (resp == -2)
           {
               throw BDGP.GetInstance().MensajeErrorReal;

           }
       }

       public static void InsertarFechaProcesoLote(DateTime fecha, string nroLote, string origen)
       {
           
           int resp = BDGP.GetInstance().Ejecute("PROC_ACTUALIZAR_FECHA_LOTE_VENTA", nroLote,fecha, origen);
           if (resp == -2)
           {
               throw new Exception(BDGP.GetInstance().MensajeErrorReal.Message+" nroLote: "+nroLote+" Fecha: "+fecha.ToString("dd/MM/yyyy")+ " Origen: "+ origen);

           }
       }

       public static void InsertarDatosLocalizacion(String nroDoc, String correlativo, String idCliente, String tipoDoc, String destinoOperacion, String idSitio,
                                                    String nroSerie, DateTime fecDoc, String idMoneda, String idUsuario)
       {
           int resp = BDGP.GetInstance().Ejecute("PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA", nroDoc,correlativo, idCliente,  tipoDoc,  destinoOperacion,  idSitio,
                                                     nroSerie,  fecDoc,  idMoneda,  idUsuario);

           if (resp == -2)
           {
               throw BDGP.GetInstance().MensajeErrorReal;

           }
       }

       public static void guardarDatosAdicionales( int jrnentry, string turno,
                   string estacion, string categoria, string numeroVale, string placa, string numeroFactura)
       {
           try
           {
               if (turno == null) { turno = ""; }

               if (estacion == null) { estacion = ""; }

               if (categoria == null) { categoria = ""; }

               if (numeroVale == null) { numeroVale = ""; }

               if (placa == null) { placa = ""; }

               if (numeroFactura == null) { numeroFactura = ""; }


               int resp = BDGP.GetInstance().Ejecute("PROC_COV_ADIC_CONS_INSERTAR_MODIFICAR", jrnentry, turno,
                   estacion, categoria, numeroVale, placa, numeroFactura);
               if (resp == -2)
               {
                   throw BDGP.GetInstance().MensajeErrorReal;
               }

           }
           catch (SqlException ex)
           {
               throw ex;
           }
           catch (DataException ex)
           {
               throw ex;
           }
       }






    }
}
