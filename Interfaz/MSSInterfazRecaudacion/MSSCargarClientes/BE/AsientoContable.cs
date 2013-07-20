using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class AsientoContable
    {

      public string nroLote { get; set; }
      public string REFRENCE { get; set; }
      public Decimal monto { get; set; }
      public string cuentaDebito { get; set; }
      public string cuentaCredito { get; set; }
      public string DSCRIPTN { get; set; }
      public string CURNCYID { get; set; }
      public DateTime TRXDATE { get; set; }
      public DateTime RVRSNGDT { get; set; }
      public DateTime EXPNDATE { get; set; }
      public DateTime EXCHDATE { get; set; }
      public string SOURCDOC { get; set; }
    }
}
