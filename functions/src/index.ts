// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
import { CallableRequest, onCall } from "firebase-functions/v2/https";
import { firestore, messaging } from "firebase-admin";
import { initializeApp } from "firebase-admin/app";

initializeApp();

// Example function to send notifications
type RequestBody = { displayName: string; message: string };

// todo - fix once we have a proper way to send notifications
exports.sendNotification = onCall(
  async ({ data: { displayName, message } }: CallableRequest<RequestBody>) => {
    const pushNotificationMessage = {
      notification: {
        title: `${displayName} just Hundy P'd!`,
        body: message,
      },
    };

    try {
      // Get all tokens from Firestore collection
      const tokensSnapshot = await firestore()
        .collection("pushNotificationTokens")
        .get();
      const tokens = tokensSnapshot.docs.map((doc) => doc.data().fcmToken);

      if (tokens.length === 0) {
        console.log("No tokens available.");
        return { success: false, message: "No tokens found." };
      }

      // Send a notification to all tokens
      const response = await messaging().sendEachForMulticast({
        ...pushNotificationMessage,
        tokens,
      });

      console.log("Notifications sent:", response);
      return { success: true, message: "Notifications sent successfully." };
    } catch (error) {
      console.error("Error sending notifications:", error);
      return { success: false, message: "Error sending notifications." };
    }
  },
);
