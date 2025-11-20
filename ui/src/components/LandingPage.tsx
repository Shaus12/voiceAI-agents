"use client";

import { ArrowRight, Bot, Zap, MessageSquare, Settings, Sparkles, TrendingUp, Shield, Check } from 'lucide-react';
import Link from 'next/link';

export default function LandingPage() {
  return (
    <div className="min-h-screen">
      {/* Animated Background */}
      <div className="fixed inset-0 -z-10 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(120,119,198,0.3),rgba(255,255,255,0))] dark:bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(120,119,198,0.15),rgba(255,255,255,0))]" />

      {/* Hero Section */}
      <div className="container relative mx-auto px-4 pt-32 pb-20">
        <div className="max-w-5xl mx-auto">
          {/* Badge */}
          <div className="flex justify-center mb-8 animate-in fade-in slide-in-from-bottom-4 duration-1000">
            <div className="inline-flex items-center gap-2 rounded-full border border-border bg-muted/50 px-4 py-1.5 text-sm backdrop-blur-sm">
              <Sparkles className="w-4 h-4 text-primary" />
              <span className="font-medium">Powered by Advanced AI</span>
            </div>
          </div>

          {/* Main Headline */}
          <div className="text-center space-y-6 animate-in fade-in slide-in-from-bottom-5 duration-1000 delay-100">
            <h1 className="text-5xl md:text-7xl font-bold tracking-tight">
              <span className="inline-block bg-gradient-to-r from-foreground to-foreground/70 bg-clip-text text-transparent">
                Build Voice AI Agents
              </span>
              <br />
              <span className="inline-block bg-gradient-to-r from-primary to-primary/60 bg-clip-text text-transparent">
                That Actually Work
              </span>
            </h1>

            <p className="text-xl md:text-2xl text-muted-foreground max-w-3xl mx-auto leading-relaxed">
              Create intelligent voice agents that understand context, speak naturally,
              and deliver exceptional experiences—all without writing a single line of code.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-8">
              <Link
                href="/workflow"
                className="group relative inline-flex items-center gap-2 px-8 py-4 text-lg font-semibold text-primary-foreground bg-primary hover:bg-primary/90 rounded-full transition-all hover:scale-105 hover:shadow-xl hover:shadow-primary/25"
              >
                Get Started Free
                <ArrowRight className="w-5 h-5 transition-transform group-hover:translate-x-1" />
              </Link>
              <Link
                href="/workflow"
                className="inline-flex items-center gap-2 px-8 py-4 text-lg font-semibold text-foreground bg-background/50 backdrop-blur-sm border border-border hover:bg-accent rounded-full transition-all"
              >
                View Demo
                <Bot className="w-5 h-5" />
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Features Grid */}
      <div className="container mx-auto px-4 py-24">
        <div className="max-w-6xl mx-auto">
          {/* Section Header */}
          <div className="text-center mb-16 space-y-4">
            <div className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/10 px-3 py-1 text-sm font-medium text-primary">
              <Zap className="w-4 h-4" />
              Features
            </div>
            <h2 className="text-4xl md:text-5xl font-bold tracking-tight">
              Everything you need to succeed
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              From rapid deployment to advanced analytics, we've got you covered
            </p>
          </div>

          {/* Feature Cards */}
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              {
                icon: Zap,
                title: "Lightning Fast",
                description: "Deploy production-ready voice agents in minutes with our intuitive visual workflow builder",
                gradient: "from-yellow-500/10 to-orange-500/10"
              },
              {
                icon: MessageSquare,
                title: "Natural Conversations",
                description: "Advanced AI models that understand context and nuance for human-like interactions",
                gradient: "from-blue-500/10 to-cyan-500/10"
              },
              {
                icon: Settings,
                title: "Full Customization",
                description: "Tailor every aspect of your agents to match your brand and use case perfectly",
                gradient: "from-purple-500/10 to-pink-500/10"
              },
              {
                icon: TrendingUp,
                title: "Real-time Analytics",
                description: "Monitor performance, track metrics, and optimize your agents with actionable insights",
                gradient: "from-green-500/10 to-emerald-500/10"
              },
              {
                icon: Shield,
                title: "Enterprise Security",
                description: "Bank-grade encryption and compliance with SOC2, GDPR, and HIPAA standards",
                gradient: "from-red-500/10 to-rose-500/10"
              },
              {
                icon: Bot,
                title: "Multi-Channel",
                description: "Deploy across phone, web, mobile, and messaging platforms from a single workflow",
                gradient: "from-indigo-500/10 to-violet-500/10"
              }
            ].map((feature, i) => (
              <div
                key={i}
                className="group relative overflow-hidden rounded-2xl border border-border bg-card p-8 transition-all hover:shadow-xl hover:shadow-primary/5 hover:-translate-y-1"
              >
                <div className={`absolute inset-0 bg-gradient-to-br ${feature.gradient} opacity-0 group-hover:opacity-100 transition-opacity`} />
                <div className="relative">
                  <div className="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center mb-5 group-hover:scale-110 transition-transform">
                    <feature.icon className="w-7 h-7 text-primary" />
                  </div>
                  <h3 className="text-xl font-semibold mb-3 text-foreground">
                    {feature.title}
                  </h3>
                  <p className="text-muted-foreground leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Social Proof / Stats */}
      <div className="container mx-auto px-4 py-24">
        <div className="max-w-5xl mx-auto">
          <div className="relative overflow-hidden rounded-3xl border border-border bg-gradient-to-br from-card to-muted/30 p-12 backdrop-blur-sm">
            <div className="absolute inset-0 bg-grid-white/5 [mask-image:radial-gradient(white,transparent_85%)]" />
            <div className="relative grid md:grid-cols-3 gap-12 text-center">
              {[
                { stat: "10x", label: "Faster Deployment", subtext: "vs traditional development" },
                { stat: "99.9%", label: "Uptime", subtext: "Enterprise-grade reliability" },
                { stat: "50+", label: "Integrations", subtext: "Connect with your tools" }
              ].map((item, i) => (
                <div key={i} className="space-y-2">
                  <div className="text-5xl md:text-6xl font-bold bg-gradient-to-br from-primary to-primary/60 bg-clip-text text-transparent">
                    {item.stat}
                  </div>
                  <div className="text-lg font-semibold text-foreground">{item.label}</div>
                  <div className="text-sm text-muted-foreground">{item.subtext}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Use Cases */}
      <div className="container mx-auto px-4 py-24">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16 space-y-4">
            <h2 className="text-4xl md:text-5xl font-bold tracking-tight">
              Built for every team
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              From startups to enterprises, voiceFX AI scales with your needs
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            {[
              {
                title: "Customer Support",
                items: ["24/7 availability", "Instant response times", "Multi-language support", "CRM integration"]
              },
              {
                title: "Sales & Lead Gen",
                items: ["Qualify leads automatically", "Schedule meetings", "Follow-up automation", "Pipeline integration"]
              },
              {
                title: "Healthcare",
                items: ["Appointment scheduling", "Patient reminders", "HIPAA compliant", "EHR integration"]
              },
              {
                title: "E-commerce",
                items: ["Order tracking", "Product recommendations", "Cart recovery", "Return management"]
              }
            ].map((useCase, i) => (
              <div
                key={i}
                className="rounded-2xl border border-border bg-card p-8 hover:shadow-lg transition-all"
              >
                <h3 className="text-2xl font-semibold mb-6 text-foreground flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Check className="w-5 h-5 text-primary" />
                  </div>
                  {useCase.title}
                </h3>
                <ul className="space-y-3">
                  {useCase.items.map((item, j) => (
                    <li key={j} className="flex items-center gap-3 text-muted-foreground">
                      <div className="w-1.5 h-1.5 rounded-full bg-primary flex-shrink-0" />
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Final CTA */}
      <div className="container mx-auto px-4 py-32">
        <div className="max-w-4xl mx-auto">
          <div className="relative overflow-hidden rounded-3xl border border-primary/20 bg-gradient-to-br from-primary/10 via-primary/5 to-background p-16 text-center backdrop-blur-sm">
            <div className="absolute inset-0 bg-grid-white/5 [mask-image:radial-gradient(white,transparent_85%)]" />
            <div className="relative space-y-8">
              <div className="space-y-4">
                <h2 className="text-4xl md:text-5xl font-bold tracking-tight">
                  Ready to transform your customer experience?
                </h2>
                <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
                  Join thousands of teams using voiceFX AI to automate conversations and scale operations.
                </p>
              </div>

              <Link
                href="/workflow"
                className="group inline-flex items-center gap-2 px-10 py-5 text-lg font-semibold text-primary-foreground bg-primary hover:bg-primary/90 rounded-full transition-all hover:scale-105 hover:shadow-2xl hover:shadow-primary/25"
              >
                Start Building Now
                <ArrowRight className="w-5 h-5 transition-transform group-hover:translate-x-1" />
              </Link>

              <p className="text-sm text-muted-foreground">
                No credit card required • Free forever plan • Setup in 5 minutes
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
