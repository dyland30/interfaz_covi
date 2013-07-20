using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class DetalleVentaBE
    {
        public string TipDoc {get; set;}

        public string Nrodoc { get; set; }

        public string Seriedoc { get; set; }

        public string Seriecaseta { get; set; }

        public string Seriedetraccion { get; set; }

        public string Nrodetraccion { get; set; }

        public string Nomcliente { get; set; }

        public string Idcliente { get; set; }

        public string Sentido { get; set; }

        public string Placa { get; set; }

        public string Codestacion { get; set; }

        public System.Nullable<System.DateTime> Fecdoc { get; set; }

        public System.Nullable<System.DateTime> FecProceso { get; set; }

        public string Codarticulo { get; set; }

        public System.Nullable<decimal> Cantidad { get; set; }

        public System.Nullable<decimal> Preuni { get; set; }

        public System.Nullable<decimal> Total { get; set; }

        public System.Nullable<decimal> Igv { get; set; }

        public System.Nullable<decimal> TotalDetraccion { get; set; }

        

        public string Nrodocasociado { get; set; }

        public System.Nullable<System.DateTime> FechaVencimientoVale { get; set; }

        public string NroTag { get; set; }

        public string Turno { get; set; }

        public string TipoDocsunat { get; set; }

        public string DestinoOperacion { get; set; }

        public System.Nullable<int> NroAsientoCont { get; set; }

        public string Estado { get; set; }

        public string Observacion { get; set; }

        public string CodLote { get; set; }

        public DetalleVentaBE() { }


    }
}
