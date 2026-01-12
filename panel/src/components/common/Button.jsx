export default function Button({
    children,
    variant = 'primary',
    type = 'button',
    disabled = false,
    onClick,
    className = '',
    ...props
}) {
    const baseClasses = 'px-6 py-3.5 rounded-2xl font-semibold transition-all duration-300 flex items-center justify-center gap-2 text-sm';

    const variants = {
        primary: 'bg-primary text-white hover:shadow-lg hover:shadow-primary/25 hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed',
        secondary: 'bg-white border border-gray-100 text-secondary hover:bg-gray-50 hover:shadow-sm disabled:opacity-50',
        danger: 'bg-red-50 text-red-600 hover:bg-red-600 hover:text-white disabled:opacity-50',
        ghost: 'bg-transparent hover:bg-gray-50 text-gray-600 hover:text-secondary',
    };

    return (
        <button
            type={type}
            disabled={disabled}
            onClick={onClick}
            className={`${baseClasses} ${variants[variant]} ${className}`}
            {...props}
        >
            {children}
        </button>
    );
}
