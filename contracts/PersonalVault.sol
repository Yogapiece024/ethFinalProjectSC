// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title PersonalVault
 * @dev Smart contract untuk menyimpan ETH dengan sistem penguncian waktu (Time-Locked).
 * Tugas Akhir - Universitas Pamulang.
 */
contract PersonalVault {
    
    // ==========================================
    // 1. CUSTOM ERRORS (Solidity 0.8.4+ Gas Efficient)
    // ==========================================
    error NotOwner();
    error FundsLocked(uint256 currentTimestamp, uint256 releaseTime);
    error InvalidUnlockTime(uint256 providedTime, uint256 minimumTime);
    error TransferFailed();

    // ==========================================
    // 2. STATE VARIABLES (Penyimpanan Data)
    // ==========================================
    address public immutable owner;
    uint256 public unlockTime;

    // ==========================================
    // 3. EVENTS (Untuk Tracking Aplikasi Luar/Etherscan)
    // ==========================================
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newTime);

    // ==========================================
    // 4. MODIFIERS (Access Control)
    // ==========================================
    // Memastikan hanya dompet owner yang bisa mengeksekusi fungsi
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    // ==========================================
    // 5. CONSTRUCTOR
    // ==========================================
    /**
     * @dev Menentukan owner asli dan mengatur waktu buka kunci pertama kali.
     * @param _unlockTime Waktu masa depan dalam bentuk Unix Timestamp (detik).
     */
    constructor(uint256 _unlockTime) {
        // Validasi: Waktu buka kunci tidak boleh di masa lalu atau saat ini
        if (_unlockTime <= block.timestamp) {
            revert InvalidUnlockTime(_unlockTime, block.timestamp);
        }
        
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    // ==========================================
    // 6. CORE FUNCTIONS (Fungsi Utama)
    // ==========================================

    /**
     * @dev Fungsi untuk menyimpan ETH ke dalam vault.
     * Hanya bisa diisi oleh owner dan harus mengirimkan ETH (> 0).
     */
    function deposit() public payable onlyOwner {
        // Memancarkan event log deposit
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Fungsi memperpanjang durasi kunci. Waktu baru harus lebih lama dari sebelumnya.
     * @param _newUnlockTime Target waktu penguncian baru (Unix Timestamp).
     */
    function extendLock(uint256 _newUnlockTime) public onlyOwner {
        // Validasi: Waktu baru harus benar-benar lebih lama dari waktu buka kunci saat ini
        if (_newUnlockTime <= unlockTime) {
            revert InvalidUnlockTime(_newUnlockTime, unlockTime);
        }

        // Efek: Perbarui state variabel di blockchain
        unlockTime = _newUnlockTime;

        // Pancarkan event perubahan waktu
        emit LockExtended(_newUnlockTime);
    }

    /**
     * @dev Fungsi menarik seluruh saldo ETH setelah masa tenggat waktu terlewati.
     * Menerapkan pola Checks-Effects-Interactions (CEI) untuk mencegah Reentrancy.
     */
    function withdraw() public onlyOwner {
        // 1. CHECKS (Validasi Kondisi)
        if (block.timestamp < unlockTime) {
            revert FundsLocked(block.timestamp, unlockTime);
        }

        // Ambil total saldo terkini di dalam kontrak
        uint256 amount = address(this).balance;
        require(amount > 0, "Tidak ada saldo untuk ditarik");

        // 2. EFFECTS (Perubahan Status Internal)
        // Memancarkan event sebelum interaksi eksternal (mengikuti pola CEI terbaik)
        emit Withdrawal(amount, block.timestamp);

        // 3. INTERACTIONS (Interaksi Eksternal / Transfer Dana)
        // Menggunakan metode low-level call{value: ...}("") demi standar keamanan modern
        (bool success, ) = owner.call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    // ==========================================
    // 7. VIEW FUNCTIONS (Fungsi Pembantu Baca Data)
    // ==========================================

    /**
     * @dev Membaca total saldo ETH di dalam kontrak saat ini.
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Fungsi fallback bawaan agar kontrak bisa menerima ETH secara langsung tanpa lewat fungsi deposit()
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}