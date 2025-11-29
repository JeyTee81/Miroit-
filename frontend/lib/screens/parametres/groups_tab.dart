import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../models/group_model.dart';
import 'create_group_screen.dart';

class GroupsTab extends StatefulWidget {
  const GroupsTab({super.key});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  final GroupService _groupService = GroupService();
  List<Group> _groups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groups = await _groupService.getGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des groupes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteGroup(Group group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le groupe "${group.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupService.deleteGroup(group.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groupe supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _loadGroups();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre d'actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Groupes d\'utilisateurs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadGroups();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau groupe'),
              ),
            ],
          ),
        ),
        const Divider(),
        // Liste des groupes
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groups.isEmpty
                  ? const Center(child: Text('Aucun groupe trouvé'))
                  : ListView.builder(
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: group.actif
                                  ? Colors.green
                                  : Colors.grey,
                              child: Text(
                                group.nom[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              group.nom,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: group.actif
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (group.description != null)
                                  Text(group.description!),
                                const SizedBox(height: 4),
                                Text(
                                  '${group.modulesAccessibles.length} module(s) • ${group.nombreUtilisateurs} utilisateur(s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateGroupScreen(group: group),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadGroups();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteGroup(group),
                                ),
                              ],
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateGroupScreen(group: group),
                                ),
                              );
                              if (result == true) {
                                _loadGroups();
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

