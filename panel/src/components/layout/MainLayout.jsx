import Sidebar from './Sidebar';

export default function MainLayout({ children }) {
    return (
        <div className="flex h-screen overflow-hidden bg-white">
            <Sidebar />
            <main className="flex-1 overflow-y-auto p-12 bg-background relative">
                {/* Subtle Decorative element */}
                <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-primary/2 rounded-full blur-[120px] -mr-64 -mt-64 pointer-events-none"></div>

                <div className="relative z-10">
                    {children}
                </div>
            </main>
        </div>
    );
}
