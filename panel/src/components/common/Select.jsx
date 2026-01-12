export default function Select({
    label,
    value,
    onChange,
    options = [],
    placeholder = 'Seçin...',
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
            <div className="relative group">
                <select
                    value={value}
                    onChange={onChange}
                    className={`w-full px-5 py-4 rounded-2xl bg-white border ${error ? 'border-red-500' : 'border-gray-100'
                        } group-focus-within:border-primary/30 outline-none transition-all duration-300 text-sm font-medium text-secondary appearance-none cursor-pointer ${className}`}
                    {...props}
                >
                    <option value="">{placeholder}</option>
                    {options.map((option) => (
                        <option key={option.value} value={option.value}>
                            {option.label}
                        </option>
                    ))}
                </select>
                <div className="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400 group-hover:text-primary transition-colors">
                    <span className="material-symbols-outlined text-[20px]">expand_more</span>
                </div>
            </div>
            {error && (
                <p className="text-red-500 text-xs font-semibold ml-1">{error}</p>
            )}
        </div>
    );
}
