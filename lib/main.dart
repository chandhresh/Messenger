import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MessengerApp());
}

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger Clone',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

// -------------------- AUTH GATE --------------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }
        if (snap.hasData) return const UserListScreen();
        return const AuthScreen();
      },
    );
  }
}

// -------------------- AUTH SCREEN --------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() => isLoading = true);
    try {
      UserCredential cred;
      if (isLogin) {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': name.text.trim(),
          'email': email.text.trim(),
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Error"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.purple.shade400],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isLogin ? "Welcome Back" : "Create Account",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 30),
                        if (!isLogin) ...[
                          TextField(
                            controller: name,
                            decoration: InputDecoration(
                              labelText: "Your Name",
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: pass,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : submit,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isLogin ? "Login" : "Sign Up",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() => isLogin = !isLogin);
                            _animController.reset();
                            _animController.forward();
                          },
                          child: Text(
                            isLogin ? "Create new account" : "Already have an account? Login",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- USER LIST SCREEN --------------------
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setOnline(true);
  }

  Future<void> _setOnline(bool online) async {
    await firestore.collection('users').doc(currentUser.uid).update({
      'isOnline': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _setOnline(false);
    super.dispose();
  }

  String chatIdFor(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Messages", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await _setOnline(false);
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('users').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snap.data!.docs.where((u) => u.id != currentUser.uid).toList();
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "No users yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              final user = u.data() as Map<String, dynamic>;
              final isOnline = user['isOnline'] == true;
              final lastSeen = user['lastSeen'] != null
                  ? DateFormat('hh:mm a').format((user['lastSeen'] as Timestamp).toDate())
                  : '';
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      Hero(
                        tag: 'avatar_${u.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade300, Colors.purple.shade300],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isOnline ? "Online" : "Last seen: $lastSeen",
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final chatId = chatIdFor(currentUser.uid, u.id);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(
                          chatId: chatId,
                          peerId: u.id,
                          peerName: user['name'],
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            )),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------- INSTAGRAM-STYLE TYPING INDICATOR --------------------
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = (1 - (value * 2 - 1).abs()) * 0.5 + 0.5;
            
            return Transform.translate(
              offset: Offset(0, -8 * scale),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// -------------------- TYPING DOT FOR APPBAR --------------------
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.blue.shade600.withOpacity(0.4 + (_animation.value * 0.6)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// -------------------- CHAT SCREEN --------------------
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String peerId;
  final String peerName;
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.peerId,
    required this.peerName,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _setOnline(true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingTimer?.cancel();
    _updateTyping(false);
    super.dispose();
  }

  Future<void> _setOnline(bool online) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'isOnline': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void _onTextChanged(String value) {
    if (value.isNotEmpty && !_isTyping) _updateTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () => _updateTyping(false));
  }

  Future<void> _updateTyping(bool typing) async {
    _isTyping = typing;
    await _firestore.collection('typing_status').doc(widget.chatId).set({
      _auth.currentUser!.uid: typing,
    }, SetOptions(merge: true));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': _auth.currentUser!.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    _controller.clear();
    _updateTyping(false);
  }

  Widget _typingIndicator() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('typing_status').doc(widget.chatId).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final data = snap.data!.data() as Map<String, dynamic>? ?? {};
        final isPeerTyping = data[widget.peerId] == true;
        
        if (!isPeerTyping) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TypingIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble(Map<String, dynamic> message, bool isMe) {
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as Timestamp?;
    final time = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate())
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                )
              : null,
          color: isMe ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey.shade600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('typing_status').doc(widget.chatId).snapshots(),
          builder: (context, typingSnap) {
            return StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(widget.peerId).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Row(
                    children: [
                      Hero(
                        tag: 'avatar_${widget.peerId}',
                        child: CircleAvatar(
                          radius: 18,
                          child: const Icon(Icons.person, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(widget.peerName),
                    ],
                  );
                }
                
                final userData = snap.data!.data() as Map<String, dynamic>;
                final isOnline = userData['isOnline'] == true;
                final lastSeen = userData['lastSeen'] != null
                    ? DateFormat('hh:mm a').format((userData['lastSeen'] as Timestamp).toDate())
                    : '';
                
                // Check if peer is typing
                final typingData = typingSnap.hasData
                    ? (typingSnap.data!.data() as Map<String, dynamic>? ?? {})
                    : {};
                final isPeerTyping = typingData[widget.peerId] == true;
                
                return Row(
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag: 'avatar_${widget.peerId}',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade300, Colors.purple.shade300],
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.peerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: isPeerTyping
                                ? Row(
                                    key: const ValueKey('typing'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'typing',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 24,
                                        height: 12,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(3, (index) {
                                            return _TypingDot(delay: index * 200);
                                          }),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    key: const ValueKey('status'),
                                    isOnline ? "Online" : "Last seen: $lastSeen",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOnline ? Colors.green : Colors.grey,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final msgs = snap.data!.docs;
                  
                  if (msgs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, 
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "No messages yet",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Say hi to start the conversation!",
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final m = msgs[i].data() as Map<String, dynamic>;
                      final isMe = m['senderId'] == user.uid;
                      return _bubble(m, isMe);
                    },
                  );
                },
              ),
            ),
            _typingIndicator(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _controller,
                            onChanged: _onTextChanged,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Message...",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade600],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}