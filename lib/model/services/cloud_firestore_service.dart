/*
import 'package:cloud_firestore/cloud_firestore.dart';


class CloudFirestoreService {
  final FirebaseFirestore db;

  const CloudFirestoreService(this.db);

  Future<String> add(LiveChatUserDetailsResponsehatResponse liveChatResponse, String userId) async {
    // Add a new document with a generated ID
    final data = liveChatResponse.toJson();
    final document = await db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(userId)
        .collection("messages")
        .add(data);
    return document.id;
  }

  Future<String> addUserDetails(
      LiveChatUserDetailsResponse liveChatUserDetailsResponse, String userId) async {
    // Initialize Firestore instance
    FirebaseFirestore db = FirebaseFirestore.instance;
    // Define the custom document ID
    String documentId = userId;
    // Create a reference to the document in the 'user_id' collection
    DocumentReference userDocRef = db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(documentId);
    // Convert the LiveChatUserDetailsResponse to JSON
    final data = liveChatUserDetailsResponse.toJson();

    DocumentReference messageDocRef =
        userDocRef; // Auto-generated ID

    try {
      await userDocRef.update(data);
      return userDocRef.id;
    } catch (e) {
      // Handle any errors that occur
      print("Error adding user details: $e");
      return "";
    }
  }

  // get all `user` collection's documents
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers(String userId) {
    return db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(userId)
        .collection("messages")
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // get all `user` collection's documents
  Future<int?> getUnReadByAdminCount(String userId) async {
    DocumentReference userDocRef = db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(userId);

    try {
      DocumentSnapshot docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        LiveChatUserDetailsResponse userDetails = LiveChatUserDetailsResponse.fromJson(docSnapshot.data() as Map<String, dynamic>);
        int? unReadByAdmin = userDetails.unReadByAdmin;
        print("Unread messages by merchant: $unReadByAdmin");
        return unReadByAdmin;
      } else {
        print("User document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> updateUnReadByAdminCount(String userId, int updatedCount) async {
    DocumentReference userDocRef = db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(userId);

    try {
      DocumentSnapshot docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        // Update the unReadByAdmin field to 0
        await userDocRef.update({'unReadByAdmin': updatedCount});
        print("Unread messages by admin count reset to 0.");
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error resetting unread messages count: $e");
    }
  }


  // get all `user` collection's documents
  Future<int?> getUnReadByMerchantCount(String userId) async {
    DocumentReference userDocRef = db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(userId);

    try {
      DocumentSnapshot docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        LiveChatUserDetailsResponse userDetails = LiveChatUserDetailsResponse.fromJson(docSnapshot.data() as Map<String, dynamic>);
        int? unReadByMerchant = userDetails.unReadByMerchant;
        print("Unread messages by merchant: $unReadByMerchant");
        return unReadByMerchant;
      } else {
        print("User document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }



  Future<void> resetUnReadByMerchantCount(String userId) async {
    DocumentReference userDocRef = db
        .collection('support_chat')
        .doc("customer")
        .collection("user_id")
        .doc(userId);

    try {
      DocumentSnapshot docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        // Update the unReadByMerchant field to 0
        await userDocRef.update({'unReadByMerchant': 0});
        print("Unread messages by merchant count reset to 0.");
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error resetting unread messages count: $e");
    }
  }


}
*/
