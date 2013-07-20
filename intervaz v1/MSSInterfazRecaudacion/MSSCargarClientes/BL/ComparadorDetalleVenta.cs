using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MSSCargarClientes.BE;

namespace MSSCargarClientes.BL
{
    public class ComparadorDetalleVenta :IEqualityComparer<DetalleVentaBE>
    {
        public bool Equals(DetalleVentaBE x, DetalleVentaBE y) {
            return x.Nrodoc.Trim().Equals(y.Nrodoc.Trim());
        
        }
        public int GetHashCode(DetalleVentaBE obj) {
            if (obj.Nrodoc != null)
            {
                return obj.Nrodoc.Trim().GetHashCode();
            }
            else {

                return 0;
            }
            
        }
    }
}
