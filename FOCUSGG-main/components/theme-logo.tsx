"use client";

import { useEffect, useState } from "react";
import { Moon, Sun } from "lucide-react";

export function Logo({ inverse = false }: { inverse?: boolean }) {
    const [failed, setFailed] = useState(false);

    return (
        <div className="flex items-center" aria-label="FOCUS.GG">
            {!failed ? (
                <img
                    className={`brand-logo h-14 w-auto object-contain ${inverse ? "brand-logo--inverse" : ""}`}
                    src="/FOCUS.GG.svg"
                    onError={() => setFailed(true)}
                    alt="Símbolo FOCUS.GG"
                />
            ) : (
                <span className="h-3 w-3 rounded-full bg-[var(--purple)]" />
            )}
            <span className={`ml-3 text-xl font-black tracking-[-.05em] ${inverse ? "text-white" : ""}`}>
                FOCUS.GG
            </span>
        </div>
    );
}

export function ThemeToggle() {
    const [dark, setDark] = useState(true);

    useEffect(() => {
        const value = localStorage.getItem("focus-theme") !== "light";
        setDark(value);
        document.documentElement.classList.toggle("dark", value);
    }, []);

    function toggle() {
        const value = !dark;
        setDark(value);
        document.documentElement.classList.toggle("dark", value);
        localStorage.setItem("focus-theme", value ? "dark" : "light");
    }

    return (
        <button className="btn !p-2.5" onClick={toggle} aria-label="Alternar tema">
            {dark ? <Sun size={18} /> : <Moon size={18} />}
        </button>
    );
}
