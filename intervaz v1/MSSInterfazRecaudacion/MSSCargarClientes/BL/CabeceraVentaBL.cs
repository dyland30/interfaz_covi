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
            BDREP helper = BDREP.GetInstance();
            List<CabeceraVentaBE> ls = new List<CabeceraVentaBE>();


            IDataReader reader = helper.CargarDataReaderProc("obtenerCabecerasFacturas", codEstacion, fecha, turno);
            if (reader == null) throw helper.MensajeErrorReal;
            ls = Util.ConvertirAEntidades<CabeceraVentaBE>(reader);
         
            return ls;
       }


       public static void crearDistribucionesCliente(CabeceraVentaBE cabecera){
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("InsertarDistribucionClienteSOP", cabecera.IdCliente.Trim(), cabecera.NroDoc.Trim());
           if (resp==-2){
               throw helper.MensajeErrorReal;

           }
       }


       public static void crearDistribucionesSOPRM(int jrentry, Int16 nroTipoDistribucion)
       {
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("InsertarAC_Financiero_SOP_RM", jrentry,nroTipoDistribucion);
           if (resp == -2)
           {
               throw helper.MensajeErrorReal;

           }
       }

       public static void InsertarValoresDefinidosUsuario(Int16 soptype, string nroDoc, DateTime fecproc, string def1, string def2, 
                                                            string def3, string def4, string def5)
       {
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("InsertarValoresDefinidosUsuarioSOP", soptype, nroDoc, fecproc, def1, def2, def3, def4, def5);
           if (resp == -2)
           {
               throw helper.MensajeErrorReal;

           }
       }


       public static void InsertarAdicionalesConsumos(string idVentana, string jrentry, int nroCampo, string  valor)
       {
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("InsertarAdicionalesConsumos", idVentana, jrentry, nroCampo, valor);
           if (resp == -2)
           {
               throw helper.MensajeErrorReal;

           }
       }


       public static void InsertarFechaProcesoVentanaPago(string idVentana, string SopNumber,string numPago, int nroCampo, DateTime valor)
       {
         
           string cod = numPago + SopNumber;
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("INSERTAR_EXTENDER_FECHA", idVentana, cod, nroCampo, valor);
           if (resp == -2)
           {
               throw helper.MensajeErrorReal;

           }
       }

       public static void InsertarFechaProcesoLote(DateTime fecha, string nroLote, string origen)
       {
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("PROC_ACTUALIZAR_FECHA_LOTE_VENTA", nroLote, fecha, origen);
           if (resp == -2)
           {
               throw helper.MensajeErrorReal;

           }
       }

       public static void InsertarDatosLocalizacion(String nroDoc, String correlativo, String idCliente, String tipoDoc, String destinoOperacion, String idSitio,
                                                    String nroSerie, DateTime fecDoc, String idMoneda, String idUsuario)
       {
           BDGP helper = BDGP.GetInstance();
           int resp = helper.Ejecute("PROC_COVI_INSERTAR_DATOS_TRIBUTARIOS_VENTA", nroDoc, correlativo, idCliente, tipoDoc, destinoOperacion, idSitio,
                                                     nroSerie,  fecDoc,  idMoneda,  idUsuario);

           if (resp == -2)
           {
               throw helper.MensajeErrorReal;

           }
       }

       public static void guardarDatosAdicionales( int jrnentry, string turno,
                   string estacion, string categoria, string numeroVale, string placa, string numeroFactura)
       {
           BDGP helper = BDGP.GetInstance();
           try
           {
               if (turno == null) { turno = ""; }

               if (estacion == null) { estacion = ""; }

               if (categoria == null) { categoria = ""; }

               if (numeroVale == null) { numeroVale = ""; }

               if (placa == null) { placa = ""; }

               if (numeroFactura == null) { numeroFactura = ""; }


               int resp = helper.Ejecute("PROC_COV_ADIC_CONS_INSERTAR_MODIFICAR", jrnentry, turno,
                   estacion, categoria, numeroVale, placa, numeroFactura);
               if (resp == -2)
               {
                   throw helper.MensajeErrorReal;
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
