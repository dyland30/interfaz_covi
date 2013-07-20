using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class ClienteBE
    {

        public string IdCliente { get; set; }

        public string NomCliente { get; set; }

        public string NombreCorto { get; set; }

        public string Direccion { get; set; }

        public System.Nullable<short> Tipopersona { get; set; }

        public string TipoDocumento { get; set; }

        public string Nombre1 { get; set; }

        public string Nombre2 { get; set; }

        public string ApePaterno { get; set; }

        public string ApeMaterno { get; set; }

        public string IdClase { get; set; }

        public string IdVendedor { get; set; }

        public string IdCondicionPago { get; set; }

        public System.Nullable<int> Prioridad { get; set; }

        public string CondNivelPrecio { get; set; }

        public string Estado { get; set; }

        public string Observacion { get; set; }


        public ClienteBE() { }
    }
}
