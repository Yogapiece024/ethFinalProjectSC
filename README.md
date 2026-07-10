# Final Test — Time-Locked Personal Vault

## Ringkasan Project Brief

Kalian akan membangun sebuah smart contract Solidity bernama **Personal Vault** — sebuah vault yang bisa mengunci (lock) ETH untuk periode waktu tertentu. Selama periode lock tersebut berlangsung, dana yang tersimpan di vault **tidak bisa ditarik oleh siapa pun**, termasuk owner-nya sendiri, sampai `unlockTime` terlewati.

Project ini menguji pemahaman kalian tentang:
- Access control (`onlyOwner`)
- Time-based logic (`block.timestamp`)
- Handling ETH secara aman (`call{value: amount}("")`)
- Event emission untuk transparansi on-chain

---

## Yang Harus Kalian Bangun

Kontrak `PersonalVault.sol` harus memiliki 3 fungsi inti berikut:

### 1. `deposit()`
- Harus `payable`, menerima ETH yang dikirim ke kontrak.
- Emit event `Deposit` setelah dana berhasil diterima.

### 2. `withdraw()`
- Hanya boleh dipanggil oleh owner (`onlyOwner`).
- Harus mengecek bahwa `unlockTime` sudah terlewati sebelum mengizinkan penarikan.
- Mentransfer **seluruh saldo** kontrak ke owner.
- Emit event `Withdrawal` setelah penarikan berhasil.

### 3. `extendLock(uint256 newTime)`
- Hanya boleh dipanggil oleh owner (`onlyOwner`).
- `newTime` harus lebih besar dari `unlockTime` yang sedang berlaku saat ini (lock hanya boleh diperpanjang, tidak boleh dipersingkat).
- Emit event `LockExtended` setelah waktu lock berhasil diperbarui.

---

## Alur Kerja

1. Develop & test dulu di [Remix](https://remix.ethereum.org) sampai semua skenario di **Testing Checklist** di bawah lolos.
2. Baru copy kode yang sudah lolos test ke file `contracts/PersonalVault.sol` di repo ini.
3. Deploy ke **Sepolia testnet** lewat Remix (Injected Provider - MetaMask).
4. Verify kontrak di **Sepolia Etherscan**.
5. Jalankan testing sekali lagi di Sepolia, catat hash transaksi untuk:
   - Deposit
   - Failed withdrawal (kepagian / sebelum unlock)
   - Successful withdrawal (setelah unlock)
6. Isi bagian **Deployment Info** di README ini dengan data kontrak kalian.
7. Commit & push, lalu submit link repo ke form pengumpulan tugas.

---

## Testing Checklist

- [ ] Deploy dengan `unlockTime` = 5 menit dari sekarang
- [ ] Deposit 1 ETH → sukses, emit `Deposit` event
- [ ] Coba withdraw sebelum waktunya → revert `FundsLocked()`
- [ ] `extendLock` ke waktu lebih lama → sukses
- [ ] Coba `extendLock` ke waktu lebih pendek → gagal
- [ ] Majukan waktu, withdraw sebagai owner → sukses, terima semua ETH
- [ ] Coba withdraw lagi → gagal (saldo kosong)

---

## Common Pitfalls

- Jangan izinkan unlock time di masa lalu saat deploy.
- Jangan izinkan non-owner melakukan withdraw.
- Jangan izinkan lock time dipersingkat lewat `extendLock`.
- Jangan pakai `transfer()` atau `send()` — pakai `call{value: amount}("")`.
- Jangan lupa emit event di setiap perubahan state.

---

## Deployment Info

> Isi bagian ini setelah kontrak kalian ter-deploy dan ter-verify di Sepolia.

- Nama & NIM: Muhammad Satrya Yoga 251011401592
- Contract Address (Sepolia): 0x441adDe71bD4CBE8dE9C1BEefa1D30Ad90d43824
- Etherscan Verified Link: https://sepolia.etherscan.io/address/0x441adDe71bD4CBE8dE9C1BEefa1D30Ad90d43824
- Unlock Time (deploy awal): 1783703608
- Tx Hash — Deposit: 0xb0cd42ba092a9a08ef23e2239c9bbc5b552d74b8defec40bbbaaeffe50563bdc
- Tx Hash — Failed Withdrawal (sebelum unlock): 0x4bfc2b968a2712c3e69b74dd81fc3455ab2e6bd53d08602ef829dfdf270ad273
- Tx Hash — Successful Withdrawal (setelah unlock): 0x45cc895dc5a8df22ac339194889d309c678c6ee042de9c3028d399ce051d16e0
