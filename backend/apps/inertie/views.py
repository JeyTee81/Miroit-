from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import (
    FamilleMateriau,
    Profil,
    Projet,
    CalculRaidisseur,
    CalculTraverse,
    CalculEI,
    Configuration
)
from .serializers import (
    FamilleMateriauSerializer,
    ProfilSerializer,
    ProjetSerializer,
    CalculRaidisseurSerializer,
    CalculTraverseSerializer,
    CalculEISerializer,
    ConfigurationSerializer,
    CalculInertieTubeSerializer
)
from .calculs import (
    calcul_inertie_tube_rectangulaire,
    calcul_pression_vent,
    calcul_inertie_raidisseur_vent,
    calcul_inertie_traverse_poids,
    selection_profil_automatique
)


class FamilleMateriauViewSet(viewsets.ModelViewSet):
    queryset = FamilleMateriau.objects.all()
    serializer_class = FamilleMateriauSerializer
    permission_classes = [IsAuthenticated]


class ProfilViewSet(viewsets.ModelViewSet):
    queryset = Profil.objects.all()
    serializer_class = ProfilSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['famille_materiau', 'actif']
    search_fields = ['code_profil', 'designation']


class ProjetViewSet(viewsets.ModelViewSet):
    queryset = Projet.objects.all()
    serializer_class = ProjetSerializer
    permission_classes = [IsAuthenticated]
    search_fields = ['numero_projet', 'nom']


class CalculRaidisseurViewSet(viewsets.ModelViewSet):
    queryset = CalculRaidisseur.objects.all()
    serializer_class = CalculRaidisseurSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['projet', 'type_charge', 'famille_materiau', 'region_vent']
    
    def perform_create(self, serializer):
        instance = serializer.save()
        self._calculer_inertie(instance)
    
    def perform_update(self, serializer):
        instance = serializer.save()
        self._calculer_inertie(instance)
    
    def _calculer_inertie(self, calcul):
        """Calcule l'inertie requise et sélectionne le profil si demandé"""
        # Calcul de la pression au vent
        pression = calcul_pression_vent(
            calcul.region_vent,
            calcul.categorie_terrain,
            calcul.hauteur_sol,
            calcul.pente_toiture
        )
        calcul.pression_vent = pression
        
        # Calcul de l'inertie requise
        inertie = calcul_inertie_raidisseur_vent(
            calcul.portee,
            calcul.trame,
            pression,
            calcul.type_charge,
            calcul.module_elasticite,
            calcul.fleche_admissible
        )
        calcul.inertie_requise = inertie
        
        # Sélection automatique du profil si demandé
        if calcul.choix_automatique_profil:
            profil = selection_profil_automatique(
                calcul.famille_materiau,
                inertie,
                'ixx'
            )
            calcul.profil_selectionne = profil
        
        calcul.save()
    
    @action(detail=False, methods=['post'])
    def calculer(self, request):
        """Action pour calculer sans sauvegarder"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        pression = calcul_pression_vent(
            data['region_vent'],
            data['categorie_terrain'],
            data.get('hauteur_sol'),
            data.get('pente_toiture')
        )
        
        inertie = calcul_inertie_raidisseur_vent(
            data['portee'],
            data['trame'],
            pression,
            data['type_charge'],
            data['module_elasticite'],
            data['fleche_admissible']
        )
        
        profil = None
        if data.get('choix_automatique_profil'):
            profil = selection_profil_automatique(
                data['famille_materiau'],
                inertie,
                'ixx'
            )
        
        return Response({
            'pression_vent': pression,
            'inertie_requise': inertie,
            'profil_selectionne': ProfilSerializer(profil).data if profil else None
        })


class CalculTraverseViewSet(viewsets.ModelViewSet):
    queryset = CalculTraverse.objects.all()
    serializer_class = CalculTraverseSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['projet', 'famille_materiau']
    
    def perform_create(self, serializer):
        instance = serializer.save()
        self._calculer_inertie(instance)
    
    def perform_update(self, serializer):
        instance = serializer.save()
        self._calculer_inertie(instance)
    
    def _calculer_inertie(self, calcul):
        """Calcule l'inertie requise et sélectionne le profil si demandé"""
        inertie = calcul_inertie_traverse_poids(
            calcul.portee,
            calcul.trame_verticale,
            calcul.poids_remplissage,
            calcul.poids_traverse,
            calcul.distance_blocage,
            calcul.module_elasticite,
            calcul.fleche_admissible
        )
        calcul.inertie_requise = inertie
        
        # Sélection automatique du profil si demandé
        if calcul.choix_automatique_profil:
            profil = selection_profil_automatique(
                calcul.famille_materiau,
                inertie,
                'iyy'
            )
            calcul.profil_selectionne = profil
        
        calcul.save()
    
    @action(detail=False, methods=['post'])
    def calculer(self, request):
        """Action pour calculer sans sauvegarder"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        inertie = calcul_inertie_traverse_poids(
            data['portee'],
            data['trame_verticale'],
            data['poids_remplissage'],
            data['poids_traverse'],
            data.get('distance_blocage', 40),
            data['module_elasticite'],
            data['fleche_admissible']
        )
        
        profil = None
        if data.get('choix_automatique_profil'):
            profil = selection_profil_automatique(
                data['famille_materiau'],
                inertie,
                'iyy'
            )
        
        return Response({
            'inertie_requise': inertie,
            'profil_selectionne': ProfilSerializer(profil).data if profil else None
        })


class CalculEIViewSet(viewsets.ModelViewSet):
    queryset = CalculEI.objects.all()
    serializer_class = CalculEISerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['projet', 'type_charge', 'famille_materiau']
    
    def perform_create(self, serializer):
        instance = serializer.save()
        self._calculer_ei(instance)
    
    def perform_update(self, serializer):
        instance = serializer.save()
        self._calculer_ei(instance)
    
    def _calculer_ei(self, calcul):
        """Calcule les valeurs E1, E2, E3, charges, inerties"""
        from .calculs import calcul_ei_menuiserie
        
        resultats = calcul_ei_menuiserie(
            calcul.type_charge,
            calcul.dimensions,
            calcul.module_elasticite,
            calcul.categorie_terrain,
            float(calcul.i_reel) if calcul.i_reel else None
        )
        
        calcul.e1 = resultats.get('e1')
        calcul.e2 = resultats.get('e2')
        calcul.e3 = resultats.get('e3')
        calcul.charge_exercee = resultats.get('charge_exercee')
        calcul.charge_admissible = resultats.get('charge_admissible')
        calcul.i_mini = resultats.get('i_mini')
        calcul.i_besoin = resultats.get('i_besoin')
        calcul.pression_calcul = resultats.get('pression_calcul')
        
        if resultats.get('i_reel'):
            calcul.i_reel = resultats.get('i_reel')
        
        calcul.save()
    
    @action(detail=False, methods=['post'])
    def calculer(self, request):
        """Action pour calculer sans sauvegarder"""
        from .calculs import calcul_ei_menuiserie
        
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        
        # i_reel peut être dans les dimensions ou directement dans les données
        i_reel = None
        if data.get('i_reel'):
            i_reel = float(data['i_reel'])
        elif isinstance(data.get('dimensions'), dict) and 'i_reel' in data['dimensions']:
            i_reel = float(data['dimensions']['i_reel'])
        
        resultats = calcul_ei_menuiserie(
            data['type_charge'],
            data['dimensions'],
            data['module_elasticite'],
            data.get('categorie_terrain', '0'),
            i_reel
        )
        
        return Response(resultats)


class ConfigurationViewSet(viewsets.ModelViewSet):
    queryset = Configuration.objects.all()
    serializer_class = ConfigurationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Retourner une seule configuration (singleton)
        config, _ = Configuration.objects.get_or_create()
        return Configuration.objects.filter(id=config.id)


class CalculUtilitaireViewSet(viewsets.ViewSet):
    """ViewSet pour les calculs utilitaires (sans sauvegarde)"""
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['post'])
    def inertie_tube(self, request):
        """Calcule l'inertie d'un tube rectangulaire creux"""
        serializer = CalculInertieTubeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        resultats = calcul_inertie_tube_rectangulaire(
            data['hauteur_cm'],
            data['largeur_cm'],
            data['epaisseur_cm']
        )
        
        return Response(resultats)

