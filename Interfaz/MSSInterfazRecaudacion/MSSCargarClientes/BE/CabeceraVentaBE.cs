using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
   public  class CabeceraVentaBE
    {
       public string Dist { get; set; }

       public string TipDoc { get; set; }

       public string NroDoc { get; set; }

       public string SerieDoc { get; set; }

       public string SerieCaseta { get; set; }

       public string NomCliente { get; set; }

       public string IdCliente { get; set; }

       public string CodEstacion { get; set; }

       public System.Nullable<System.DateTime> Fecdoc { get; set; }

       public System.Nullable<System.DateTime> FecProceso { get; set; }

       public string Moneda { get; set; }

       public string TipoDocSunat { get; set; }

       public string Estado { get; set; }

       public string CodLote { get; set; }

       public string Turno { get; set; }

       public string NroDocAsociado { get; set; }

       public string DestinoOperacion { get; set; }


       public CabeceraVentaBE() { }
    }
}
