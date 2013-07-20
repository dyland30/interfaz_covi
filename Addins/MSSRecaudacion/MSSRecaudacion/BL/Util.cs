using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.Data;
using System.Collections;

namespace MSSRecaudacion.BL
{
    public static class Util
    {
        

        public static List<T> ConvertirAEntidades<T>
 (IDataReader dr)
    where T : new()
        {
            Type businessEntityType = typeof(T);
            List<T> entitys = new List<T>();
            Hashtable hashtable = new Hashtable();
            PropertyInfo[] properties = businessEntityType.GetProperties();
            foreach (PropertyInfo info in properties)
            {
                hashtable[info.Name.ToUpper()] = info;
            }
            while (dr.Read())
            {

                T newObject = new T();
                for (int index = 0; index < dr.FieldCount; index++)
                {
                    PropertyInfo info = (PropertyInfo)
                                        hashtable[dr.GetName(index).ToUpper()];
                    if ((info != null) && info.CanWrite)
                    {
                        Object valor = dr.GetValue(index);
                        if (valor == DBNull.Value)
                        {
                            valor = null;
                        }
                        info.SetValue(newObject, valor, null);
                    }
                }
                entitys.Add(newObject);


            }
            dr.Close();
            return entitys;
        }
    }
}


