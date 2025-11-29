from rest_framework import serializers
from .models import User, Group


class GroupSerializer(serializers.ModelSerializer):
    """Serializer pour les groupes"""
    modules_accessibles = serializers.SerializerMethodField()
    nombre_utilisateurs = serializers.SerializerMethodField()
    
    class Meta:
        model = Group
        fields = [
            'id', 'nom', 'description',
            'acces_commerciale', 'acces_menuiserie', 'acces_vitrages',
            'acces_optimisation', 'acces_stock', 'acces_travaux',
            'acces_planning', 'acces_tournees', 'acces_crm',
            'acces_inertie', 'acces_parametres', 'acces_logs',
            'actif', 'created_at', 'updated_at',
            'modules_accessibles', 'nombre_utilisateurs'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_modules_accessibles(self, obj):
        """Retourne la liste des modules accessibles"""
        return obj.get_modules_accessibles()
    
    def get_nombre_utilisateurs(self, obj):
        """Retourne le nombre d'utilisateurs dans le groupe"""
        return obj.users.count()


class UserSerializer(serializers.ModelSerializer):
    is_superuser = serializers.BooleanField(read_only=True)
    groupe_nom = serializers.CharField(source='groupe.nom', read_only=True, allow_null=True)
    groupe_id = serializers.UUIDField(source='groupe.id', read_only=True, allow_null=True)
    modules_accessibles = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'nom', 'prenom', 'role',
            'groupe', 'groupe_id', 'groupe_nom', 'actif', 'is_superuser',
            'last_login', 'modules_accessibles'
        ]
        read_only_fields = ['id', 'is_superuser', 'last_login', 'modules_accessibles']
    
    def get_modules_accessibles(self, obj):
        """Retourne la liste des modules accessibles"""
        return obj.get_modules_accessibles()


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'nom', 'prenom', 'role', 'groupe', 'actif']

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    """Serializer pour la mise à jour d'un utilisateur"""
    
    class Meta:
        model = User
        fields = ['username', 'email', 'nom', 'prenom', 'role', 'groupe', 'actif']
    
    def update(self, instance, validated_data):
        # Ne pas mettre à jour le mot de passe ici
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
