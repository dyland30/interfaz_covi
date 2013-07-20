using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSRecaudacion.BE
{
    public class CasetaBE
    {
        string _idCaseta;

        public string IdCaseta
        {
            get { return _idCaseta; }
            set { _idCaseta = value; }
        }
        string _descripcion;

        public string Descripcion
        {
            get { return _descripcion; }
            set { _descripcion = value; }
        }

        string _idEstacion;

        public string IdEstacion
        {
            get { return _idEstacion; }
            set { _idEstacion = value; }
        }
    }
}
