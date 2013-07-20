using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSRecaudacion.BE;
using System.Data;
using MSSRecaudacion.DAO;

namespace MSSRecaudacion.BL
{
    public static class CasetaBL
    {
        public static List<CasetaBE> obtenerCasetasPeaje(string cod_estacion)
        {

            List<CasetaBE> listaCasetas = new List<CasetaBE>();

            IDataReader reader = BDGP.GetInstance().CargarDataReaderProc("PROC_OBTENER_CASETAS_ESTACION_TODAS", cod_estacion);
            if (reader != null)
            {
                listaCasetas = Util.ConvertirAEntidades<CasetaBE>(reader);
            }

            return listaCasetas;

        }

        public static List<CasetaBE> listaCasetas()
        {

            List<CasetaBE> listaCasetas = new List<CasetaBE>();

            IDataReader reader = BDGP.GetInstance().CargarDataReaderProc("PROC_LISTA_CASETAS");
            if (reader != null)
            {
                listaCasetas = Util.ConvertirAEntidades<CasetaBE>(reader);
            }

            return listaCasetas;

        }


    }
}
