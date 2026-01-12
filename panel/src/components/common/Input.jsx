export default function Input({
    label,
    type = 'text',
    value,
    onChange,
    placeholder,
    error,
    required = false,
    className = '',
    ...props
}) {
    return (
        <div className="space-y-2">
            {label && (
                <label className="text-[13px] font-bold text-gray-500 uppercase tracking-wider ml-1">
                    {label}
                    {required && <span className="text-primary ml-1">*</span>}
                </label>
            )}
            <input
                type={type}
                value={value}
                onChange={onChange}
                placeholder={placeholder}
                className={`w-full px-5 py-4 rounded-2xl bg-white border ${error ? 'border-red-500' : 'border-gray-100'
                    } focus:border-primary/30 focus:bg-white focus:shadow-lg focus:shadow-primary/5 outline-none transition-all duration-300 text-sm font-medium text-secondary placeholder:text-gray-300 ${className}`}
                {...props}
            />
            {error && (
                <p className="text-red-500 text-xs font-semibold ml-1">{error}</p>
            )}
        </div>
    );
}
