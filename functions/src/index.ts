import { CallableRequest, onCall } from "firebase-functions/v2/https";
import { firestore, messaging } from "firebase-admin";
import { initializeApp } from "firebase-admin/app";

initializeApp();

// Example function to send notifications
type RequestBody = { displayName: string; message: string; uid: string };

// todo - replace w/ a DB call to get a random message
const generateRandomMessage = (displayName: string) => {
  const messages = [
    `${displayName} deserves it 🥹`,
    "You didn’t just Hundy P; you demolished the P and made it your bitch. Respect! (generated by Chad lol)",
    "Great success!!",
  ];
  return messages[Math.floor(Math.random() * messages.length)];
};

// Cloud Function to send notifications and save event to Firestore
exports.sendNotification = onCall(
  async ({
    data: { displayName, message, uid },
  }: CallableRequest<RequestBody>) => {
    const missingFields = [];
    if (!uid) missingFields.push("uid");
    if (!displayName) missingFields.push("displayName");

    if (missingFields.length > 0) {
      return {
        success: false,
        message: `The following fields are missing: ${missingFields.join(", ")}`,
      };
    }

    const body = message != null ? message : generateRandomMessage(displayName);
    const pushNotificationMessage = {
      notification: {
        title: `${displayName} just Hundy P'd!`,
        body,
      },
    };

    try {
      // Get all tokens from Firestore collection
      const tokensSnapshot = await firestore()
        .collection("pushNotificationTokens")
        .get();
      const tokens = tokensSnapshot.docs.map((doc) => doc.data().fcmToken);

      if (tokens.length === 0) {
        console.log("No tokens available. Event will not be saved.");
        return { success: false, message: "No tokens found. Event not saved." };
      }

      // Save the event to Firestore
      const eventDocRef = firestore().collection("hundyPEvents").doc();
      await eventDocRef.set({
        uid, // User ID
        message: body, // Message sent
        timestamp: firestore.FieldValue.serverTimestamp(), // Server-generated timestamp
      });
      console.log(`Saved Hundy P event to Firestore: ${eventDocRef.id}`);

      try {
        // Send a notification to all tokens
        const response = await messaging().sendEachForMulticast({
          ...pushNotificationMessage,
          tokens,
        });

        console.log("Notifications sent:", response);
        return {
          success: true,
          message: "Notifications sent and event saved successfully.",
        };
      } catch (notificationError) {
        console.error("Error sending notifications:", notificationError);

        // Rollback the saved event if notification fails
        await eventDocRef.delete();
        console.log(`Rolled back event: ${eventDocRef.id}`);

        return {
          success: false,
          message: "Failed to send notifications. Event rolled back.",
        };
      }
    } catch (error) {
      console.error("Error processing request:", error);
      return {
        success: false,
        message: "An error occurred while processing the request.",
      };
    }
  },
);
