## tidalcycles-rs

[tidalcycles-rs](https://crates.io/crates/tidalcycles-rs) makes it very easy to audition these sounds.

```
cargo install tidalcycles-rs
tidalcycles-rs
tcrs_dirt_dl install
tidalcycles-rs --spawn -f
tcrs_dirt_sample_iter
```

This will install a live coding environment, install these sounds, run the sever, and play all the dirt banks.

# 🎧 uxn-st — Dirt Branch

This branch (`dirt`) contains **WAV-converted** versions of the raw sound files from the main branch.  
It’s meant for easy use with **[SuperDirt](https://github.com/musikinformatik/SuperDirt)** in **[TidalCycles](https://tidalcycles.org/)**.

The files are about 264MB on disk.

---

## 🔽 Download or Clone

If you only want the converted WAV files (and not the entire repo history), use:

```bash
# clone just the dirt branch
git clone --branch dirt --single-branch --depth 1 https://github.com/davehorner/uxn-st.git
cd uxn-st
```

Or simply **download the ZIP**:

👉 [Download WAVs (dirt branch)](https://github.com/davehorner/uxn-st/archive/refs/heads/dirt.zip)

---

## 🧩 Install into SuperDirt

1. Find your SuperDirt samples directory:

   - **macOS/Linux:** `~/SuperCollider/superdirt/samples/`
   - **Windows:** `C:\Users\<you>\AppData\Local\SuperCollider\superdirt\samples\`

2. Copy or symlink this folder there:

   ```bash
   # Example (Linux/macOS)
   ln -s /path/to/uxn-st ~/SuperCollider/superdirt/samples/uxn-st
   ```

3. Restart SuperDirt in SuperCollider:

   ```supercollider
   SuperDirt.start
   ```

4. Test in TidalCycles:

   ```haskell
   d1 $ sound "uxn-st:1"
   ```

---

## ℹ️ About

**uxn-st** is a collection of sound textures inspired by the [Uxn](https://wiki.xxiivv.com/site/uxn.html) ecosystem.  
The `dirt` branch exists so you can plug these samples straight into SuperDirt without converting formats yourself.
If you want the uxn ready to embed files, check the main branch.
