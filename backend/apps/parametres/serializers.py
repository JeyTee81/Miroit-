from rest_framework import serializers
from .models import Imprimante


class ImprimanteSerializer(serializers.ModelSerializer):
    connection_string = serializers.SerializerMethodField()

    class Meta:
        model = Imprimante
        fields = [
            'id', 'nom', 'type_imprimante', 'nom_systeme',
            'adresse_ip', 'port', 'protocole', 'nom_reseau',
            'format_papier', 'orientation', 'actif',
            'imprimante_par_defaut', 'description',
            'connection_string', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'connection_string', 'created_at', 'updated_at']

    def get_connection_string(self, obj):
        return obj.get_connection_string()




