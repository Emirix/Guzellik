<!DOCTYPE html>

<html class="light" lang="en">

<head>
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <title>Profil Sayfası</title>
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com" rel="preconnect" />
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect" />
    <link
        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@200;300;400;500;600;700;800&amp;display=swap"
        rel="stylesheet" />
    <!-- Material Symbols -->
    <link
        href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap"
        rel="stylesheet" />
    <link
        href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap"
        rel="stylesheet" />
    <!-- Tailwind CSS with Config -->
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#e23661",
                        "background-light": "#fdfbfb", /* Creamy white */
                        "background-dark": "#211115",
                        "gold": "#C5A059", /* Added Gold for accents */
                        "nude": "#F3E8EA", /* Light nude for backgrounds */
                    },
                    fontFamily: {
                        "display": ["Plus Jakarta Sans", "sans-serif"]
                    },
                    borderRadius: { "DEFAULT": "1rem", "lg": "1.5rem", "xl": "2rem", "full": "9999px" },
                    boxShadow: {
                        'soft': '0 4px 20px -2px rgba(226, 54, 97, 0.1)',
                        'gold': '0 4px 15px -2px rgba(197, 160, 89, 0.25)',
                    }
                },
            },
        }
    </script>
    <style>
        .material-symbols-outlined {
            font-variation-settings:
                'FILL' 1,
                'wght' 400,
                'GRAD' 0,
                'opsz' 24
        }

        /* Custom scrollbar hide for clean UI */
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }

        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
    <style>
        body {
            min-height: max(884px, 100dvh);
        }
    </style>
</head>

<body class="bg-background-light dark:bg-background-dark font-display antialiased text-[#1b0e11] dark:text-white">
    <div class="relative flex h-full min-h-screen w-full flex-col overflow-x-hidden pb-24">
        <!-- Top App Bar -->
        <div
            class="sticky top-0 z-20 bg-background-light/95 dark:bg-background-dark/95 backdrop-blur-sm px-4 py-3 flex items-center justify-between border-b border-nude dark:border-white/5">
            <div
                class="flex size-10 shrink-0 items-center justify-center rounded-full active:bg-nude dark:active:bg-white/10 transition-colors cursor-pointer">
                <span class="material-symbols-outlined text-[#1b0e11] dark:text-white">arrow_back</span>
            </div>
            <h2 class="text-[#1b0e11] dark:text-white text-lg font-bold leading-tight flex-1 text-center">Profilim</h2>
            <div class="flex w-12 items-center justify-end cursor-pointer group">
                <span class="text-primary text-sm font-bold group-hover:opacity-80 transition-opacity">Düzenle</span>
            </div>
        </div>
        <!-- Profile Header -->
        <div class="flex flex-col items-center pt-6 pb-2 px-6">
            <div class="relative group cursor-pointer">
                <!-- Avatar Ring with Gold Gradient -->
                <div
                    class="absolute -inset-1 bg-gradient-to-tr from-gold to-primary rounded-full opacity-70 blur-sm group-hover:opacity-100 transition duration-300">
                </div>
                <div
                    class="relative h-28 w-28 rounded-full border-4 border-background-light dark:border-background-dark overflow-hidden bg-gray-200">
                    <img alt="Portrait of a smiling woman with long hair" class="h-full w-full object-cover"
                        data-alt="Close up portrait of a young woman smiling outdoors"
                        src="https://lh3.googleusercontent.com/aida-public/AB6AXuB85iwnK7nEpb51oHgintdnP3oVo3gtPePQqyXTlRzYgkW1d_5gyY1j-zl3dniGpzIzkXmLbg9rhSt_AUApfC6HWWEgSBZXphXoBcgnCJELVGVrC7njz2Gm7nSnygYNHQD_UelHU8pqjLJmP05GeWcrfcITef-0Fha3B4WyVxCCRlGUrtmNDTujGgl2F-UDLNQLWLRI2IAkXycxY70-BR6nS3NVOzDUn46-4VgqfkjCbePVq27IiW5HbB1IRNfVLbcFymtPyAeO0A" />
                </div>
                <!-- Edit Icon Badge -->
                <div
                    class="absolute bottom-1 right-1 bg-primary text-white p-1.5 rounded-full border-[3px] border-background-light dark:border-background-dark flex items-center justify-center shadow-lg">
                    <span class="material-symbols-outlined text-[14px] leading-none">edit</span>
                </div>
            </div>
            <div class="mt-4 flex flex-col items-center gap-1">
                <h1 class="text-2xl font-bold text-[#1b0e11] dark:text-white">Ayşe Yılmaz</h1>
                <p class="text-gray-500 dark:text-gray-400 text-sm">ayse.yilmaz@gmail.com</p>
                <!-- Membership Badge -->
                <div
                    class="mt-2 flex items-center gap-1.5 px-3 py-1 rounded-full bg-gradient-to-r from-[#FFF8E7] to-[#FFF0D4] border border-gold/30 shadow-sm">
                    <span class="material-symbols-outlined text-gold text-[16px]">stars</span>
                    <span class="text-xs font-bold text-yellow-800 tracking-wide uppercase">Gold Üye</span>
                </div>
            </div>
        </div>
        <!-- Stats Section -->
        <div class="flex w-full px-4 py-6">
            <div class="grid grid-cols-3 gap-3 w-full">
                <!-- Stat 1 -->
                <div
                    class="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-white/5 border border-nude dark:border-white/10 shadow-sm">
                    <span class="text-xl font-bold text-[#1b0e11] dark:text-white">12</span>
                    <span class="text-xs font-medium text-gray-500 dark:text-gray-400 mt-1">Randevu</span>
                </div>
                <!-- Stat 2 -->
                <div
                    class="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-white/5 border border-nude dark:border-white/10 shadow-sm">
                    <span class="text-xl font-bold text-[#1b0e11] dark:text-white">5</span>
                    <span class="text-xs font-medium text-gray-500 dark:text-gray-400 mt-1">Favori</span>
                </div>
                <!-- Stat 3 -->
                <div
                    class="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-white/5 border border-nude dark:border-white/10 shadow-sm">
                    <span class="text-xl font-bold text-primary">150</span>
                    <span class="text-xs font-medium text-gray-500 dark:text-gray-400 mt-1">Puan</span>
                </div>
            </div>
        </div>
        <!-- Menu List -->
        <div class="flex flex-col px-4 gap-4">
            <!-- Group 1: Main Actions -->
            <div
                class="flex flex-col bg-white dark:bg-white/5 rounded-2xl overflow-hidden shadow-sm border border-nude dark:border-white/5">
                <!-- Item: Randevularım -->
                <div
                    class="group flex items-center justify-between p-4 cursor-pointer hover:bg-nude/30 dark:hover:bg-white/10 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="flex size-10 items-center justify-center rounded-full bg-primary/10 text-primary">
                            <span class="material-symbols-outlined">calendar_month</span>
                        </div>
                        <span class="text-base font-medium text-[#1b0e11] dark:text-white">Randevularım</span>
                    </div>
                    <span class="material-symbols-outlined text-gray-400">chevron_right</span>
                </div>
                <div class="h-px w-full bg-gray-100 dark:bg-white/5 ml-16"></div>
                <!-- Item: Favorilerim -->
                <div
                    class="group flex items-center justify-between p-4 cursor-pointer hover:bg-nude/30 dark:hover:bg-white/10 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="flex size-10 items-center justify-center rounded-full bg-primary/10 text-primary">
                            <span class="material-symbols-outlined">favorite</span>
                        </div>
                        <span class="text-base font-medium text-[#1b0e11] dark:text-white">Favorilerim</span>
                    </div>
                    <span class="material-symbols-outlined text-gray-400">chevron_right</span>
                </div>
                <div class="h-px w-full bg-gray-100 dark:bg-white/5 ml-16"></div>
                <!-- Item: Cüzdanım -->
                <div
                    class="group flex items-center justify-between p-4 cursor-pointer hover:bg-nude/30 dark:hover:bg-white/10 transition-colors">
                    <div class="flex items-center gap-4">
                        <div class="flex size-10 items-center justify-center rounded-full bg-primary/10 text-primary">
                            <span class="material-symbols-outlined">account_balance_wallet</span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-base font-medium text-[#1b0e11] dark:text-white">Cüzdanım</span>
                            <span class="text-xs text-gray-400">Son işlem: Dün</span>
                        </div>
                    </div>
                    <span class="material-symbols-outlined text-gray-400">chevron_right</span>
                </div>
            </div>
            <!-- Group 2: Settings & Support -->
            <div
                class="flex flex-col bg-white dark:bg-white/5 rounded-2xl overflow-hidden shadow-sm border border-nude dark:border-white/5">
                <!-- Item: Bildirim Ayarları -->
                <div
                    class="group flex items-center justify-between p-4 cursor-pointer hover:bg-nude/30 dark:hover:bg-white/10 transition-colors">
                    <div class="flex items-center gap-4">
                        <div
                            class="flex size-10 items-center justify-center rounded-full bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-gray-300">
                            <span class="material-symbols-outlined">notifications</span>
                        </div>
                        <span class="text-base font-medium text-[#1b0e11] dark:text-white">Bildirim Ayarları</span>
                    </div>
                    <span class="material-symbols-outlined text-gray-400">chevron_right</span>
                </div>
                <div class="h-px w-full bg-gray-100 dark:bg-white/5 ml-16"></div>
                <!-- Item: Ayarlar -->
                <div
                    class="group flex items-center justify-between p-4 cursor-pointer hover:bg-nude/30 dark:hover:bg-white/10 transition-colors">
                    <div class="flex items-center gap-4">
                        <div
                            class="flex size-10 items-center justify-center rounded-full bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-gray-300">
                            <span class="material-symbols-outlined">settings</span>
                        </div>
                        <span class="text-base font-medium text-[#1b0e11] dark:text-white">Genel Ayarlar</span>
                    </div>
                    <span class="material-symbols-outlined text-gray-400">chevron_right</span>
                </div>
                <div class="h-px w-full bg-gray-100 dark:bg-white/5 ml-16"></div>
                <!-- Item: Yardım & Destek -->
                <div
                    class="group flex items-center justify-between p-4 cursor-pointer hover:bg-nude/30 dark:hover:bg-white/10 transition-colors">
                    <div class="flex items-center gap-4">
                        <div
                            class="flex size-10 items-center justify-center rounded-full bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-gray-300">
                            <span class="material-symbols-outlined">help</span>
                        </div>
                        <span class="text-base font-medium text-[#1b0e11] dark:text-white">Yardım &amp; Destek</span>
                    </div>
                    <span class="material-symbols-outlined text-gray-400">chevron_right</span>
                </div>
            </div>
            <!-- Logout Button -->
            <button
                class="mt-2 w-full flex items-center justify-center gap-2 p-4 rounded-xl border border-primary/20 text-primary bg-white dark:bg-transparent dark:border-primary/40 font-bold active:bg-primary/5 transition-colors">
                <span class="material-symbols-outlined text-[20px]">logout</span>
                Çıkış Yap
            </button>
            <p class="text-center text-xs text-gray-400 mt-2">Versiyon 2.1.0</p>
        </div>
        <!-- Bottom Navigation Bar (Fixed) -->
        <div
            class="fixed bottom-0 left-0 w-full bg-white dark:bg-[#1a0d10] border-t border-gray-100 dark:border-white/5 pb-6 pt-3 px-6 z-50 shadow-[0_-5px_20px_-5px_rgba(0,0,0,0.05)]">
            <div class="flex justify-between items-center">
                <!-- Home -->
                <div class="flex flex-col items-center gap-1 opacity-50 hover:opacity-100 cursor-pointer">
                    <span class="material-symbols-outlined text-2xl font-light">home</span>
                    <span class="text-[10px] font-medium">Anasayfa</span>
                </div>
                <!-- Search -->
                <div class="flex flex-col items-center gap-1 opacity-50 hover:opacity-100 cursor-pointer">
                    <span class="material-symbols-outlined text-2xl font-light">search</span>
                    <span class="text-[10px] font-medium">Keşfet</span>
                </div>
                <!-- Map -->
                <div class="flex flex-col items-center gap-1 opacity-50 hover:opacity-100 cursor-pointer">
                    <span class="material-symbols-outlined text-2xl font-light">map</span>
                    <span class="text-[10px] font-medium">Harita</span>
                </div>
                <!-- Profile (Active) -->
                <div class="flex flex-col items-center gap-1 text-primary cursor-pointer">
                    <span class="material-symbols-outlined text-2xl fill-1">person</span>
                    <span class="text-[10px] font-bold">Profilim</span>
                </div>
            </div>
        </div>
    </div>
</body>

</html>