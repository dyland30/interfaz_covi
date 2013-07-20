using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class ClaseClienteBE
    {
        public string CLASSID{get;set;}
        public string PlanImpuestos {get; set;}
        public string MetodoEnvio {get; set;}
        public string CondicionPago {get; set;}
        public string IdMoneda {get; set;}
        public string CuentaEfectivo{get; set;}
        public string CuentaxCobrar{get; set;}
        public string CuentaVentas{get; set;}
        public string CuentaCostoVenta{get; set;}
        public string CuentaInventario{get; set;}
        public string CuentaCondicionesDtosTomados{get; set;}
        public string CuentaCondicionesDtosDisponibles{get; set;}
        public string CuentaCargosFinancieros{get; set;}
        public string CuentaCancelaciones{get; set;}
        public string CuentaCancelacionesSobrepago{get; set;}
        public string CuentaDevolucionesPedidosVenta { get; set; }
        public string IdVendedor {get; set;}
        public string IdTerritorio {get; set;}
        public Int16 CicloEstado {get; set;}



    }
}
