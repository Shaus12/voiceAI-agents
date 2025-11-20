# voiceFX AI

<h3 align="center">⭐ <strong>If you find value in this project, PLEASE STAR the Github repository to help others discover our FOSS platform!</strong></h3>

<p align="center">
  <a href="https://docs.voicefx.com">
    <img src="https://img.shields.io/badge/docs-https://docs.voicefx.com-blue.svg" alt="Docs: https://docs.voicefx.com">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-BSD%202--Clause-blue.svg" alt="License: BSD 2-Clause">
  </a>
  <a href="https://join.slack.com/t/voicefx-community/shared_invite/zt-3czr47sw5-MSg1J0kJ7IMPOCHF~03auQ">
    <img src="https://img.shields.io/badge/chat-on%20Slack-4A154B?logo=slack" alt="Slack Community">
  </a>
  <a href="https://www.docker.com/">
    <img src="https://img.shields.io/badge/docker-ready-blue?logo=docker" alt="Docker Ready">
  </a>
</p>

voiceFX helps you build your own voice agents with an easy drag-and-drop workflow builder. It's the fastest way to build voice AI agents - from zero to working bot in under 2 minutes (our hard SLA standards).

- **100% open source**, self-hostable platform with built-in AI testing personas and flexible LLM/TTS/STT integration
- **Maintained by YC alumni and exit founders**, ensuring the future of voice AI stays open, not monopolized

## 🎥 Demo Video

<div align="center">
  <a href="https://www.tella.tv/video/cmgbysbsz00kw0bjm2qnc5f1d/view">
    <img src="docs/images/video_thumbnail_1.png" alt="Watch voiceFX AI Demo Video" width="80%" style="border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
  </a>
  <br>
  <em>Click to watch a 2-minute demo of voiceFX AI in action</em>
</div>

## 🚀 Get Started

The only command you need to run:

##### Download and setup voiceFX on your local machine

> **Note**
> We collect anonymous usage data to improve the product. You can opt out by setting the `ENABLE_TELEMETRY` to `false` in the below command.

```bash
curl -o docker-compose.yaml https://raw.githubusercontent.com/voicefx-hq/voicefx/main/docker-compose.yaml && REGISTRY=ghcr.io/voicefx-hq ENABLE_TELEMETRY=true docker compose up --pull always
```

> **Note**
> First startup may take 2-3 minutes to download all images. Once running, open http://localhost:3010 to create your first AI voice assistant!
> For common issues and solutions, see 🔧 **[Troubleshooting](docs/troubleshooting.md)**.

### 🎙️ Your First Voice Bot

1. **Open Dashboard**: Launch [http://localhost:3010](http://localhost:3010) on your browser
2. **Choose Call Type**: Select **Inbound** or **Outbound** calling.
3. **Name Your Bot**: Use a short two-word name (e.g., _Lead Qualification_).
4. **Describe Use Case**: In 5–10 words (e.g., _Screen insurance form submissions for purchase intent_).
5. **Launch**: Your bot is ready! Open the bot and click **Web Call** to talk to it.
6. **No API Keys Needed**: We auto-generate voiceFX API keys so you can start immediately. You can switch to your own keys anytime.
7. **Default Access**: Includes voiceFX's own LLMs, STT, and TTS stack by default.
8. **Bring Your Own Keys**: Optionally connect your own API keys for LLMs, STT, TTS, or telephony providers like Twilio.

## Quick Summary

⚡ 2-Minute Setup: Hard SLA standards - from zero to working voice bot in under 2 minutes

- 🔧 Minimal setup: Just [run docker command](#get-started) and you're live
- 🤖 AI Testing Personas: Test your bots with LoopTalk AI that mimics real customer interactions
- 🔓 100% Open Source: Every line of code is open - no hidden logic, no black boxes
- 🔄 Flexible Integration: Bring your own LLM, TTS, or STT - or use voiceFX's API's
- ☁️ Self-Host or Cloud: Run locally or use our hosted version at app.voicefx.com

## Features

### Voice Capabilities

- Telephony: Built-in Twilio integration (easily add others)
- Languages: English support (expandable to other languages)
- Custom Models: Bring your own TTS/STT models
- Real-time Processing: Low-latency voice interactions

### Developer Experience

- Zero Config Start: Auto-generated API keys for instant testing
- Python-Based: Built on Python for easy customization
- Docker-First: Containerized for consistent deployments
- Modular Architecture: Swap components as needed

### Testing & Quality

- LoopTalk (Beta): Create AI personas to test your voice agents
- Workflow Testing: Test specific workflow IDs with automated calls
- Real-world Simulation: AI personas that mimic actual customer behavior

## Architecture

Architecture diagram _(coming soon)_

## Deployment Options

### 🆓 Free Testing (Recommended to Start)

Test VoiceFX AI for FREE before committing to paid hosting:

- **[One-Click Deploy](ONE-CLICK-DEPLOY.md)** - Deploy to Render in 2 minutes
- **[Free Hosting Guide](DEPLOY-FREE-TESTING.md)** - Railway, Fly.io, or Oracle Cloud options

### 💻 Local Development

Refer [prerequisites](https://docs.voicefx.com/getting-started/prerequisites) and [first steps](#-get-started)

### 🚀 Production Deployment (Self-Hosted)

Complete production deployment guides available:

- **[Beginner's Guide](DEPLOY-FOR-BEGINNERS.md)** - Step-by-step for absolute beginners
- **[Full Deployment Guide](DEPLOYMENT.md)** - Comprehensive technical documentation
- **[Quick Reference](DEPLOYMENT-QUICKREF.md)** - Command cheat sheet for daily operations
- **[Monitoring Guide](MONITORING.md)** - Setup alerts and monitoring

**Quick production deploy:**
```bash
# Copy environment template
cp .env.production.example .env.production

# Edit with your settings
nano .env.production

# Deploy
./scripts/setup-ssl.sh
./scripts/deploy.sh setup
./scripts/deploy.sh start
```

### ☁️ Cloud Version

Visit [https://www.voicefx.com](https://www.voicefx.com/) for our managed cloud offering.

## 📚Documentation

You can go to [https://docs.voicefx.com](https://docs.voicefx.com/) for our documentation.

## 🤝Community & Support

- GitHub Issues: Report bugs or request features
- Slack: Our Slack community is not just for support — it's the cornerstone of voiceFX AI contributions. Here, you can:
  - Connect with maintainers and other contributors
  - Discuss issues and features before coding
  - Get help with setup and debugging
  - Stay up to date with contribution sprints

👉 Join us → voiceFX Community Slack

## 🙌 Contributing

We love contributions! voiceFX AI is 100% open source and we intend to keep it that way.

### Getting Started

- Fork the repository
- Create your feature branch (git checkout -b feature/AmazingFeature)
- Commit your changes (git commit -m 'Add some AmazingFeature')
- Push to the branch (git push origin feature/AmazingFeature)
- Open a Pull Request

## 📄 License

voiceFX AI is licensed under the [BSD 2-Clause License](LICENSE)- the same license as projects that were used in building voiceFX AI, ensuring compatibility and freedom to use, modify, and distribute.

## 🏢 About

Built with ❤️ by **voiceFX** (Zansat Technologies Private Limited)
Founded by YC alumni and exit founders committed to keeping voice AI open and accessible to everyone.

<br><br><br>

  <p align="center">
    <a href="https://github.com/voicefx-hq/voicefx/stargazers">⭐ Star us on GitHub</a> |
    <a href="https://app.voicefx.com">☁️ Try Cloud Version</a> |
    <a href="https://join.slack.com/t/voicefx-community/shared_invite/zt-3czr47sw5-MSg1J0kJ7IMPOCHF~03auQ">💬 Join Slack</a>
  </p>
