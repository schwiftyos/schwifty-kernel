
// MARK: Externs
@_extern(c, "enable_simd_sse")
private func enableSSE()

@_extern(c, "enable_simd_avx")
private func enableAVX()

@_extern(c, "enable_simd_avx512")
private func enableAVX512()

// MARK: Init
@_optimize(none)
func initSIMD() {
    logger.log(staticString: "SIMD: initializing...")

    var result = CPUIDResult()

    // check standard features
    cpuidLow(leaf: 1, subleaf: 0, result: &result)

    let hasSSE = (result.edx & (1 << 25)) != 0
    if hasSSE {
        loadSSE(&result)
    }
    logger.log(staticString: "SIMD: initialized")
}

private func loadSSE(_ result: inout CPUIDResult) {
    logger.log(staticString: "loadSSE: enabling...")
    enableSSE()
    logger.log(staticString: "loadSSE: enabled")

    // check osxsave & avx
    cpuidLow(leaf: 1, subleaf: 0, result: &result)

    let hasAVX = (result.ecx & (1 << 28)) != 0
    let hasOSXSAVE = (result.ecx & (1 << 27)) != 0
    guard hasOSXSAVE && hasAVX else { return }
    loadAVX(&result)
}

private func loadAVX(_ result: inout CPUIDResult) {
    logger.log(staticString: "loadAVX: enabling...")
    enableAVX()
    logger.log(staticString: "loadAVX: enabled")

    // check for AVX-512
    cpuidLow(leaf: 7, subleaf: 0, result: &result)
    let hasAVX512F = (result.ebx & (1 << 16)) != 0
    if hasAVX512F {
        logger.log(staticString: "loadAVX: enabling AVX-512...")
        enableAVX512()
        logger.log(staticString: "loadAVX: enabled AVX-512")
    }
}