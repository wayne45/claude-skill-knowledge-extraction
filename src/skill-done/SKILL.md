---
name: done
description: >
  End-of-session workflow: runs knowledge extraction then lets the user exit.
  Use /done instead of typing "exit" to ensure session learnings are captured.
user-invocable: true
---

# Session Done

Run the `/knowledge-extraction` skill to extract and save knowledge from this session.

After knowledge extraction completes (or if no knowledge-worthy items are found), tell the user they can now type `exit` to leave.