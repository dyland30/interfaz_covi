using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSRecaudacion.BE;
using MSSRecaudacion.DAO;
using System.Data;

namespace MSSRecaudacion.BL
{
    public static class ResumenBL
    {
        public static List<ResumenBE> obtenerResumen()
        {

            List<ResumenBE> listaResumen = new List<ResumenBE>();

            IDataReader reader = BDREP.GetInstance().CargarDataReaderProc("OBTENER_RESUMEN");
            if (reader != null)
            {
                listaResumen = Util.ConvertirAEntidades<ResumenBE>(reader);
            }
            return listaResumen;
        }

        public static void limpiarResumen()
        {

            int resp = BDREP.GetInstance().Ejecute("LIMPIAR_RESUMEN");
            if (resp == -2)
            {
                throw BDREP.GetInstance().MensajeErrorReal;
            }
            
        }
    }
}
