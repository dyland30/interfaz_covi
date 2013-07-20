using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;
using System.Data;

namespace MSSCargarClientes.BL
{
    public static class ClaseClienteBL
    {
        public static ClaseClienteBE obtenerClaseCliente(string idClase)
        {
            BDGP helper = BDGP.GetInstance();
            IDataReader reader = helper.CargarDataReaderProc("COVI_OBTENER_CLASE_CLIENTE", idClase);
            if (reader == null) throw helper.getErrorReal();
            ClaseClienteBE cli = null;
            List<ClaseClienteBE> ls = Util.ConvertirAEntidades<ClaseClienteBE>(reader);
            if (ls != null && ls.Count > 0)
            {
                cli = ls.First<ClaseClienteBE>();
            }
            return cli;

        }
    }
}
