namespace MSSRecaudacion
{
    partial class FrmInterfazRecaudacion
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
            this.lbl_usuario = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.dt_fecha = new System.Windows.Forms.DateTimePicker();
            this.cmb_turno = new System.Windows.Forms.ComboBox();
            this.btn_documentos = new System.Windows.Forms.Button();
            this.btn_clientes = new System.Windows.Forms.Button();
            this.pictureBox = new System.Windows.Forms.PictureBox();
            this.backgroundWorker = new System.ComponentModel.BackgroundWorker();
            this.cmb_lista_estaciones = new System.Windows.Forms.ComboBox();
            this.labelProgress = new System.Windows.Forms.TextBox();
            this.btn_ver_resumen = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).BeginInit();
            this.SuspendLayout();
            // 
            // lbl_usuario
            // 
            this.lbl_usuario.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbl_usuario.BackColor = System.Drawing.SystemColors.GradientInactiveCaption;
            this.lbl_usuario.Location = new System.Drawing.Point(273, 0);
            this.lbl_usuario.Name = "lbl_usuario";
            this.lbl_usuario.Size = new System.Drawing.Size(300, 24);
            this.lbl_usuario.TabIndex = 0;
            this.lbl_usuario.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label1
            // 
            this.label1.ForeColor = System.Drawing.Color.Red;
            this.dexLabelProvider.SetLinkField(this.label1, "cmb_lista_estaciones");
            this.label1.Location = new System.Drawing.Point(12, 46);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(110, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Código de Estación :";
            // 
            // label3
            // 
            this.label3.ForeColor = System.Drawing.Color.Red;
            this.dexLabelProvider.SetLinkField(this.label3, "dt_fecha");
            this.label3.Location = new System.Drawing.Point(12, 66);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(107, 13);
            this.label3.TabIndex = 3;
            this.label3.Text = "Fecha de Proceso:";
            // 
            // label4
            // 
            this.label4.ForeColor = System.Drawing.Color.Red;
            this.dexLabelProvider.SetLinkField(this.label4, "cmb_turno");
            this.label4.Location = new System.Drawing.Point(11, 88);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(49, 13);
            this.label4.TabIndex = 4;
            this.label4.Text = "Turno:";
            // 
            // dt_fecha
            // 
            this.dt_fecha.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dt_fecha.Location = new System.Drawing.Point(125, 61);
            this.dt_fecha.Name = "dt_fecha";
            this.dt_fecha.Size = new System.Drawing.Size(109, 20);
            this.dt_fecha.TabIndex = 7;
            // 
            // cmb_turno
            // 
            this.cmb_turno.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmb_turno.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmb_turno.FormattingEnabled = true;
            this.cmb_turno.Items.AddRange(new object[] {
            "(Todos)",
            "Mañana",
            "Tarde",
            "Noche"});
            this.cmb_turno.Location = new System.Drawing.Point(125, 82);
            this.cmb_turno.Name = "cmb_turno";
            this.cmb_turno.Size = new System.Drawing.Size(215, 21);
            this.cmb_turno.TabIndex = 8;
            // 
            // btn_documentos
            // 
            this.btn_documentos.BackColor = System.Drawing.Color.Transparent;
            this.dexButtonProvider.SetButtonType(this.btn_documentos, Microsoft.Dexterity.Shell.DexButtonType.ToolbarWithSeparator);
            this.btn_documentos.FlatAppearance.BorderSize = 0;
            this.btn_documentos.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btn_documentos.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btn_documentos.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btn_documentos.Image = global::MSSRecaudacion.Properties.Resources.Field_NotePresent;
            this.btn_documentos.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btn_documentos.Location = new System.Drawing.Point(3, 0);
            this.btn_documentos.Name = "btn_documentos";
            this.btn_documentos.Size = new System.Drawing.Size(128, 24);
            this.btn_documentos.TabIndex = 9;
            this.btn_documentos.Text = "Cargar Documentos";
            this.btn_documentos.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btn_documentos.UseVisualStyleBackColor = false;
            this.btn_documentos.Click += new System.EventHandler(this.button1_Click);
            // 
            // btn_clientes
            // 
            this.btn_clientes.BackColor = System.Drawing.Color.Transparent;
            this.dexButtonProvider.SetButtonType(this.btn_clientes, Microsoft.Dexterity.Shell.DexButtonType.ToolbarWithSeparator);
            this.btn_clientes.FlatAppearance.BorderSize = 0;
            this.btn_clientes.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btn_clientes.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btn_clientes.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btn_clientes.Image = global::MSSRecaudacion.Properties.Resources.customers;
            this.btn_clientes.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btn_clientes.Location = new System.Drawing.Point(136, 0);
            this.btn_clientes.Name = "btn_clientes";
            this.btn_clientes.Size = new System.Drawing.Size(109, 24);
            this.btn_clientes.TabIndex = 10;
            this.btn_clientes.Text = "Cargar Clientes";
            this.btn_clientes.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btn_clientes.UseVisualStyleBackColor = false;
            this.btn_clientes.Click += new System.EventHandler(this.btn_clientes_Click);
            // 
            // pictureBox
            // 
            this.pictureBox.Location = new System.Drawing.Point(351, 52);
            this.pictureBox.Name = "pictureBox";
            this.pictureBox.Size = new System.Drawing.Size(48, 48);
            this.pictureBox.TabIndex = 11;
            this.pictureBox.TabStop = false;
            // 
            // backgroundWorker
            // 
            this.backgroundWorker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.backgroundWorker_DoWork);
            this.backgroundWorker.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.backgroundWorker_RunWorkerCompleted);
            // 
            // cmb_lista_estaciones
            // 
            this.cmb_lista_estaciones.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmb_lista_estaciones.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmb_lista_estaciones.FormattingEnabled = true;
            this.cmb_lista_estaciones.Location = new System.Drawing.Point(126, 40);
            this.cmb_lista_estaciones.Name = "cmb_lista_estaciones";
            this.cmb_lista_estaciones.Size = new System.Drawing.Size(212, 21);
            this.cmb_lista_estaciones.TabIndex = 13;
            this.cmb_lista_estaciones.SelectedIndexChanged += new System.EventHandler(this.cmb_lista_estaciones_SelectedIndexChanged);
            // 
            // labelProgress
            // 
            this.labelProgress.BackColor = System.Drawing.SystemColors.ButtonFace;
            this.labelProgress.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.labelProgress.Location = new System.Drawing.Point(414, 39);
            this.labelProgress.Multiline = true;
            this.labelProgress.Name = "labelProgress";
            this.labelProgress.ReadOnly = true;
            this.labelProgress.Size = new System.Drawing.Size(147, 121);
            this.labelProgress.TabIndex = 15;
            // 
            // btn_ver_resumen
            // 
            this.btn_ver_resumen.BackColor = System.Drawing.SystemColors.Control;
            this.btn_ver_resumen.Location = new System.Drawing.Point(414, 166);
            this.btn_ver_resumen.Name = "btn_ver_resumen";
            this.btn_ver_resumen.Size = new System.Drawing.Size(147, 23);
            this.btn_ver_resumen.TabIndex = 17;
            this.btn_ver_resumen.Text = "Ver Resumen";
            this.btn_ver_resumen.UseVisualStyleBackColor = false;
            this.btn_ver_resumen.Click += new System.EventHandler(this.btn_ver_resumen_Click);
            // 
            // FrmInterfazRecaudacion
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(573, 219);
            this.Controls.Add(this.btn_ver_resumen);
            this.Controls.Add(this.labelProgress);
            this.Controls.Add(this.cmb_lista_estaciones);
            this.Controls.Add(this.pictureBox);
            this.Controls.Add(this.btn_clientes);
            this.Controls.Add(this.btn_documentos);
            this.Controls.Add(this.cmb_turno);
            this.Controls.Add(this.dt_fecha);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.lbl_usuario);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.HResizeable = false;
            this.Location = new System.Drawing.Point(0, 0);
            this.MaximizeBox = false;
            this.Name = "FrmInterfazRecaudacion";
            this.Text = "Interfaz de Recaudacion";
            this.VResizeable = false;
            this.Load += new System.EventHandler(this.FrmInterfazRecaudacion_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lbl_usuario;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.DateTimePicker dt_fecha;
        private System.Windows.Forms.ComboBox cmb_turno;
        private System.Windows.Forms.Button btn_documentos;
        private System.Windows.Forms.Button btn_clientes;
        private System.Windows.Forms.PictureBox pictureBox;
        private System.ComponentModel.BackgroundWorker backgroundWorker;
        private System.Windows.Forms.ComboBox cmb_lista_estaciones;
        private System.Windows.Forms.TextBox labelProgress;
        private System.Windows.Forms.Button btn_ver_resumen;
    }
}

