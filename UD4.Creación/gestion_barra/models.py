from odoo import models, fields, api

class TabernaIncidencia(models.Model):
    _name = 'taberna.incidencia'
    _description = 'Incidencias en la Taberna'

    cliente = fields.Char(string='Cliente', required=True)
    descripcion = fields.Char(string='Descripción')
    nivel_alcohol = fields.Integer(string='Nivel de Alcohol')
    expulsar = fields.Boolean(string='Expulsar', compute='_calcular_expulsion')
    pagado = fields.Boolean(string='Pagado', default=False)

    @api.depends('nivel_alcohol')
    def _calcular_expulsion(self):
        for registro in self:
            if registro.nivel_alcohol > 10:
                registro.expulsar = True
            else:
                registro.expulsar = False
