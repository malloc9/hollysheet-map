import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/role.dart';
import '../../providers/user_provider.dart';
import '../../widgets/member_card.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUser(user.uid);
      userProvider.loadPendingUsers();
      userProvider.loadMembers();
      userProvider.loadAdmins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser.role != Role.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/map');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/map'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Members'),
            Tab(text: 'Admins'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingList(userProvider),
          _buildMembersList(userProvider),
          _buildAdminsList(userProvider),
        ],
      ),
    );
  }

  Widget _buildPendingList(UserProvider userProvider) {
    if (userProvider.pendingUsers.isEmpty) {
      return const Center(child: Text('No pending users'));
    }
    return ListView.builder(
      itemCount: userProvider.pendingUsers.length,
      itemBuilder: (context, index) {
        final user = userProvider.pendingUsers[index];
        return MemberCard(
          user: user,
          onApprove: () => userProvider.approveUser(user.uid),
          onReject: () => userProvider.rejectUser(user.uid),
        );
      },
    );
  }

  Widget _buildMembersList(UserProvider userProvider) {
    if (userProvider.members.isEmpty) {
      return const Center(child: Text('No members'));
    }
    return ListView.builder(
      itemCount: userProvider.members.length,
      itemBuilder: (context, index) {
        final user = userProvider.members[index];
        return MemberCard(
          user: user,
          onRemove: () => userProvider.removeUser(user.uid),
          onPromote: () => userProvider.promoteToAdmin(user.uid),
        );
      },
    );
  }

  Widget _buildAdminsList(UserProvider userProvider) {
    if (userProvider.admins.isEmpty) {
      return const Center(child: Text('No admins'));
    }
    return ListView.builder(
      itemCount: userProvider.admins.length,
      itemBuilder: (context, index) {
        final user = userProvider.admins[index];
        return MemberCard(user: user);
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
