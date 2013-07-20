using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSRecaudacion.BE;
using MSSRecaudacion.DAO;
using System.Data;

namespace MSSRecaudacion.BL
{
    public static class EstacionesBL
    {
        public static List<EstacionesBE> obtenerEstacionesPeajeTodas() {

            List<EstacionesBE> listaEstaciones = new List<EstacionesBE>();

            IDataReader reader = BDGP.GetInstance().CargarDataReaderProc("ObtenerEstacionesPeajeTodas");
            if (reader !=null)
            {
                 listaEstaciones = Util.ConvertirAEntidades<EstacionesBE>(reader);
            }
            return listaEstaciones;
        }

        public static List<EstacionesBE> obtenerEstacionesPeaje()
        {

            List<EstacionesBE> listaEstaciones = new List<EstacionesBE>();

            IDataReader reader = BDGP.GetInstance().CargarDataReaderProc("ObtenerEstacionesPeaje");
            if (reader != null)
            {
                listaEstaciones = Util.ConvertirAEntidades<EstacionesBE>(reader);
            }
            return listaEstaciones;
        }

    }
}
