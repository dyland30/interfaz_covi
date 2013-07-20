using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace MSSCargarClientes.BE
{
    public static class CompanyGPBE
    {
        //CURID -> Z-US$
        public static Int32 ObtenerCantidadDecimalesPorMoneda(string IdMoneda)
        {
            Int32 cantDec = 0;
            var query = string.Format(@"SELECT DECPLCUR-1 CANTDEC FROM DYNAMICS..MC40200 WHERE CURNCYID = '{0}'", IdMoneda);
            DataTable dt =  BDGP.GetInstance().CargarDataTableSQL(query, "formatoMoneda");
            Nullable<Int32> numDec= dt.Rows[0].Field <Nullable<Int32>> ("CANTDEC");
            if(numDec!=null){
                cantDec = numDec.Value;
            }
            return cantDec;

        }
    }
}
