using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;
using System.Data;

namespace MSSCargarClientes.BL
{
    public static class EstacionesBL
    {
        public static List<EstacionesBE> obtenerEstacionesPeajeTodas() {
            BDGP helper = BDGP.GetInstance();
            List<EstacionesBE> listaEstaciones = new List<EstacionesBE>();

            IDataReader reader = helper.CargarDataReaderProc("ObtenerEstacionesPeajeTodas");
            if (reader == null) throw helper.getErrorReal();
            listaEstaciones = Util.ConvertirAEntidades<EstacionesBE>(reader);
            return listaEstaciones;
        }

        public static List<EstacionesBE> obtenerEstacionesPeaje()
        {
            BDGP helper = BDGP.GetInstance();
            List<EstacionesBE> listaEstaciones = new List<EstacionesBE>();

            IDataReader reader = helper.CargarDataReaderProc("ObtenerEstacionesPeaje");
            if (reader == null) throw helper.getErrorReal();
            listaEstaciones = Util.ConvertirAEntidades<EstacionesBE>(reader);
            
            return listaEstaciones;
        }

    }
}
