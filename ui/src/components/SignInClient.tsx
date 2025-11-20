"use client";

import { Loader2 } from 'lucide-react';
import dynamic from 'next/dynamic';

import Footer from './Footer';
import LandingPage from './LandingPage';

// Only load Stack's SignIn component when Stack provider is active
const SignIn = dynamic(
  () => import('@stackframe/stack').then(mod => ({ default: mod.SignIn })),
  { ssr: false, loading: () => <Loader2 className="w-5 h-5 animate-spin text-muted-foreground" /> }
);

export default function SignInClient() {
  const authProvider = process.env.NEXT_PUBLIC_AUTH_PROVIDER || 'stack';

  if (authProvider !== 'stack') {
    return (
      <>
        <LandingPage />
        <Footer />
      </>
    );
  }

  return (
    <>
      <SignIn />
      <Footer />
    </>
  );
}
