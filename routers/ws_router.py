import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

router = APIRouter()


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    Handles WebSocket connections.
    Accepts a connection, receives a message, and echoes it back.
    """
    await websocket.accept()
    print(f"WebSocket connection accepted from {websocket.client}")
    try:
        while True:
            # Receive a message from the client
            data = await websocket.receive_text()
            print(f"Received from client: {data}")

            # Send the received message back to the client
            await websocket.send_text(f"Message received: {data}")

    except WebSocketDisconnect:
        print(f"WebSocket connection disconnected from {websocket.client}")
    finally:
        # You can add cleanup code here if needed
        pass
