namespace MSSRecaudacion
{
    partial class Resumen
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            this.label1 = new System.Windows.Forms.Label();
            this.dgv_resumen = new System.Windows.Forms.DataGridView();
            this.codEstacion = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.serieCaseta = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.turno = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.lote = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.procesados = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.errores = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.lbl_usuario = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgv_resumen)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(0, 29);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(173, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "RESUMEN DEL ENVÍO";
            // 
            // dgv_resumen
            // 
            this.dgv_resumen.AllowUserToAddRows = false;
            this.dgv_resumen.AllowUserToDeleteRows = false;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.InactiveBorder;
            this.dgv_resumen.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dgv_resumen.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgv_resumen.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.codEstacion,
            this.serieCaseta,
            this.turno,
            this.lote,
            this.procesados,
            this.errores});
            this.dgv_resumen.Location = new System.Drawing.Point(3, 49);
            this.dgv_resumen.Name = "dgv_resumen";
            this.dgv_resumen.ReadOnly = true;
            this.dgv_resumen.RowHeadersVisible = false;
            this.dgv_resumen.Size = new System.Drawing.Size(506, 150);
            this.dgv_resumen.TabIndex = 1;
            // 
            // codEstacion
            // 
            this.codEstacion.DataPropertyName = "codEstacion";
            this.codEstacion.HeaderText = "Id. Estación";
            this.codEstacion.Name = "codEstacion";
            this.codEstacion.ReadOnly = true;
            this.codEstacion.Width = 90;
            // 
            // serieCaseta
            // 
            this.serieCaseta.DataPropertyName = "serieCaseta";
            this.serieCaseta.HeaderText = "Id. Caseta";
            this.serieCaseta.Name = "serieCaseta";
            this.serieCaseta.ReadOnly = true;
            this.serieCaseta.Width = 90;
            // 
            // turno
            // 
            this.turno.DataPropertyName = "turno";
            this.turno.HeaderText = "Turno";
            this.turno.Name = "turno";
            this.turno.ReadOnly = true;
            this.turno.Width = 50;
            // 
            // lote
            // 
            this.lote.DataPropertyName = "lote";
            this.lote.HeaderText = "Lote";
            this.lote.Name = "lote";
            this.lote.ReadOnly = true;
            this.lote.Width = 90;
            // 
            // procesados
            // 
            this.procesados.DataPropertyName = "procesados";
            this.procesados.HeaderText = "Procesados";
            this.procesados.Name = "procesados";
            this.procesados.ReadOnly = true;
            this.procesados.Width = 90;
            // 
            // errores
            // 
            this.errores.DataPropertyName = "errores";
            this.errores.HeaderText = "Errores";
            this.errores.Name = "errores";
            this.errores.ReadOnly = true;
            this.errores.Width = 90;
            // 
            // lbl_usuario
            // 
            this.lbl_usuario.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbl_usuario.BackColor = System.Drawing.SystemColors.GradientInactiveCaption;
            this.lbl_usuario.Location = new System.Drawing.Point(215, 0);
            this.lbl_usuario.Name = "lbl_usuario";
            this.lbl_usuario.Size = new System.Drawing.Size(300, 24);
            this.lbl_usuario.TabIndex = 2;
            this.lbl_usuario.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // Resumen
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(515, 258);
            this.Controls.Add(this.lbl_usuario);
            this.Controls.Add(this.dgv_resumen);
            this.Controls.Add(this.label1);
            this.Location = new System.Drawing.Point(0, 0);
            this.Name = "Resumen";
            this.Text = "Resumen";
            this.Load += new System.EventHandler(this.Resumen_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgv_resumen)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.DataGridView dgv_resumen;
        private System.Windows.Forms.DataGridViewTextBoxColumn codEstacion;
        private System.Windows.Forms.DataGridViewTextBoxColumn serieCaseta;
        private System.Windows.Forms.DataGridViewTextBoxColumn turno;
        private System.Windows.Forms.DataGridViewTextBoxColumn lote;
        private System.Windows.Forms.DataGridViewTextBoxColumn procesados;
        private System.Windows.Forms.DataGridViewTextBoxColumn errores;
        private System.Windows.Forms.Label lbl_usuario;
    }
}

