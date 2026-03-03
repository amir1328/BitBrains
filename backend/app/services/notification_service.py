"""
Firebase Cloud Messaging (FCM) notification service.
Initialises Firebase Admin SDK once and provides helper methods
for sending push notifications to individual users or topics.
"""

import logging
import os
import json

import firebase_admin
from firebase_admin import credentials, messaging

logger = logging.getLogger(__name__)

_app_initialized = False


def _init_firebase():
    """Lazily initialise the Firebase Admin SDK."""
    global _app_initialized
    if _app_initialized:
        return
        
    try:
        # 1. Try to load from raw JSON string (better for cloud deployments like Railway)
        firebase_json_str = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
        if firebase_json_str:
            cred_dict = json.loads(firebase_json_str)
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
            _app_initialized = True
            logger.info("Firebase Admin SDK initialised from JSON string successfully.")
            return

        # 2. Fallback to file path (better for local dev)
        service_account_path = os.getenv(
            "FIREBASE_SERVICE_ACCOUNT_PATH", "firebase-service-account.json"
        )
        if not os.path.exists(service_account_path):
            logger.warning(
                f"Firebase service account file not found: {service_account_path}. "
                "Push notifications will be disabled."
            )
            return

        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        _app_initialized = True
        logger.info("Firebase Admin SDK initialised from file successfully.")
    except Exception as e:
        logger.error(f"Failed to initialise Firebase Admin SDK: {e}")


# Initialise at module import time
_init_firebase()


def send_notification(
    token: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    """
    Send a push notification to a single device.
    Returns True on success, False on failure.
    """
    if not _app_initialized:
        logger.warning("Firebase not initialised — skipping notification.")
        return False
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=token,
            android=messaging.AndroidConfig(priority="high"),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default")
                )
            ),
        )
        messaging.send(message)
        logger.info(f"Notification sent to token {token[:20]}...")
        return True
    except Exception as e:
        logger.error(f"Failed to send notification: {e}")
        return False


def send_multicast(
    tokens: list[str],
    title: str,
    body: str,
    data: dict | None = None,
) -> int:
    """
    Send a push notification to multiple devices.
    Returns the number of successful sends.
    """
    if not _app_initialized or not tokens:
        return 0
    try:
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            tokens=tokens,
            android=messaging.AndroidConfig(priority="high"),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default")
                )
            ),
        )
        response = messaging.send_each_for_multicast(message)
        logger.info(
            f"Multicast: {response.success_count}/{len(tokens)} sent successfully."
        )
        return response.success_count
    except Exception as e:
        logger.error(f"Failed to send multicast notification: {e}")
        return 0


def send_topic_notification(
    topic: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    """
    Send a notification to all devices subscribed to a topic.
    Topic format: e.g. 'new_material', 'room_general'
    """
    if not _app_initialized:
        return False
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            topic=topic,
        )
        messaging.send(message)
        logger.info(f"Topic notification sent to topic '{topic}'.")
        return True
    except Exception as e:
        logger.error(f"Failed to send topic notification: {e}")
        return False
