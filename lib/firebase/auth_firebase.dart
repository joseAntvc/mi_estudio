import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFirebase {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;

  Future<bool> createUser(String email, String password) async{
    try {
      final userCredential = await fireAuth.createUserWithEmailAndPassword(email: email, password: password);
      userCredential.user!.sendEmailVerification(); //Es para poder enviar un correo y que el usuario se identifique
      return true;
    } catch (e) { return false; }
  }

  Future<String?> loginUser(String email, String password) async {
    try{
      final credencials = await fireAuth.signInWithEmailAndPassword(email: email, password: password);
      if(credencials.user != null && !credencials.user!.emailVerified) return "verificacion";
      return null;
    } catch (e){ return "error"; }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await fireAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) { return false; }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "cancelado";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return null; // Todo bien
    } catch (e) {
      return "error";
    }
  }

  Future<void> actualizarFoto(String url) async {
    final user = getUser();
    await user?.updatePhotoURL(url);
    await user?.reload();
  }

  //Obtener el usuario actual
  User? getUser() {
    return fireAuth.currentUser;
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    // Cierra sesión en Firebase
    await fireAuth.signOut();
    // Cierra sesión en Google
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }
}
