export default function Modal({ isOpen, onClose, onConfirm, title, children, confirmText = 'Onayla', cancelText = 'İptal', type = 'info' }) {
    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-[110] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-secondary/40 backdrop-blur-sm" onClick={onClose}></div>
            <div className="relative glass-card bg-white rounded-3xl p-8 max-w-md w-full shadow-2xl animate-in zoom-in duration-200">
                <h3 className="text-xl font-bold mb-4">{title}</h3>
                <div className="text-gray-600 mb-8">{children}</div>
                <div className="flex gap-3">
                    <Button variant="secondary" className="flex-1" onClick={onClose}>{cancelText}</Button>
                    <Button
                        className={`flex-1 ${type === 'danger' ? '!bg-red-500 hover:!bg-red-600 shadow-red-500/20' : ''}`}
                        onClick={onConfirm}
                    >
                        {confirmText}
                    </Button>
                </div>
            </div>
        </div>
    );
}
