"use client";

import { CircleDollarSign } from 'lucide-react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import React from 'react';

import { useUserConfig } from '@/context/UserConfigContext';
import { useAuth } from '@/lib/auth';
import ThemeToggle from '@/components/ThemeSwitcher';

// Conditionally load Stack components only when using Stack auth
const StackUserButton = React.lazy(() =>
    import('@stackframe/stack').then(mod => ({ default: mod.UserButton }))
);
const StackTeamSwitcher = React.lazy(() =>
    import('@stackframe/stack').then(mod => ({ default: mod.SelectedTeamSwitcher }))
);

interface BaseHeaderProps {
    headerActions?: React.ReactNode,
    backButton?: React.ReactNode,
    showFeaturesNav?: boolean
}

export default function BaseHeader({ headerActions, backButton, showFeaturesNav = true }: BaseHeaderProps) {
    const { permissions } = useUserConfig();
    const { provider, user } = useAuth();
    const pathname = usePathname();
    const router = useRouter();

    const isActive = (path: string) => {
        return pathname.startsWith(path);
    };

    const hasAdminPermission = Array.isArray(permissions) && permissions.some(p => p.id === 'admin');


    return (
        <header className="sticky top-0 z-50 w-full border-b bg-background">
            <div className="container mx-auto px-4 py-4">
                <nav className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <Link href="/" className="text-xl font-semibold text-foreground hover:text-muted-foreground">
                            voiceFX AI
                        </Link>
                        {backButton}
                        {showFeaturesNav && (
                            <div className="flex items-center gap-4 ml-8">
                                {hasAdminPermission && (
                                    <>
                                        <Link
                                            href="/workflow"
                                            className={`text-sm font-medium transition-colors hover:text-primary ${isActive('/workflow') ? 'text-primary' : 'text-muted-foreground'
                                                }`}
                                        >
                                            Workflows
                                        </Link>
                                        <Link
                                            href="/campaigns"
                                            className={`text-sm font-medium transition-colors hover:text-primary ${isActive('/campaigns') ? 'text-primary' : 'text-muted-foreground'
                                                }`}
                                        >
                                            Campaigns
                                        </Link>
                                    </>
                                )}
                                <Link
                                    href="/usage"
                                    className={`text-sm font-medium transition-colors hover:text-primary ${isActive('/usage') ? 'text-primary' : 'text-muted-foreground'
                                        }`}
                                >
                                    Usage
                                </Link>
                                <Link
                                    href="/reports"
                                    className={`text-sm font-medium transition-colors hover:text-primary ${isActive('/reports') ? 'text-primary' : 'text-muted-foreground'
                                        }`}
                                >
                                    Reports
                                </Link>
                            </div>
                        )}
                    </div>
                    <div className="flex-1 flex justify-center">
                        {headerActions}
                    </div>

                    {/* Use key to force remount when user changes to avoid hooks issues */}
                    <div className="flex items-center gap-5" key={user ? 'logged-in' : 'logged-out'}>
                        <ThemeToggle />
                        {provider === 'stack' ? (
                            <React.Suspense fallback={
                                <div className="flex items-center gap-5">
                                    {/* Match StackTeamSwitcher's internal skeleton */}
                                    <div className="h-9 w-40 animate-pulse bg-muted rounded" />
                                    {/* Match StackUserButton dimensions: h-[34px] w-[34px] */}
                                    <div className="h-[34px] w-[34px] animate-pulse bg-muted rounded-full" />
                                </div>
                            }>
                                <div className="w-40 shrink-0">
                                    <StackTeamSwitcher
                                        onChange={() => {
                                            router.refresh();
                                        }}
                                    />
                                </div>
                                <StackUserButton
                                    extraItems={[{
                                        text: 'Usage',
                                        icon: <CircleDollarSign strokeWidth={2} size={16} />,
                                        onClick: () => router.push('/usage')
                                    }]}
                                />
                            </React.Suspense>
                        ) : null}
                    </div>
                </nav>
            </div>
        </header>
    );
}
