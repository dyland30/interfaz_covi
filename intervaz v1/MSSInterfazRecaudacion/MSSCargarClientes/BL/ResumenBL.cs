using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;

namespace MSSCargarClientes.BL
{
    public static class ResumenBL
    {

        public static void InsertarResumen(ResumenBE res) {
            BDREP helper = BDREP.GetInstance();
            int resp = helper.Ejecute("INSERTAR_RESUMEN",res.CodEstacion,res.SerieCaseta,
                res.Turno,res.Procesados,res.Errores,res.Lote);
            if (resp == -2)
            {
                throw helper.MensajeErrorReal;

            }
        }
    }
}
