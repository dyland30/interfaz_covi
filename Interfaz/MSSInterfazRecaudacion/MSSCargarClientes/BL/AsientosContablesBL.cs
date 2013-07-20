using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;
using System.Data;

namespace MSSCargarClientes.BL
{
    public class AsientosContablesBL
    {

        public static int crearAsientosContables(AsientoContable a)

        {
            int jrentry = 0;
            DataTable tabla  = BDGP.GetInstance().CargarDataTableProc("covi_insertarAsientosContables", a.nroLote,
                a.REFRENCE,a.monto,a.cuentaDebito,a.cuentaCredito, a.DSCRIPTN, 
                a.CURNCYID, a.TRXDATE, a.RVRSNGDT, a.EXPNDATE,a.EXCHDATE, a.SOURCDOC);
            if (BDGP.GetInstance().MensajeErrorReal!=null)
            {
                throw BDGP.GetInstance().MensajeErrorReal;
            }
            
            if (tabla!=null && tabla.Rows.Count>0)
            {
                jrentry = tabla.Rows[0].Field<Int32>(0);

            }
            return jrentry;
        }

   }
}
