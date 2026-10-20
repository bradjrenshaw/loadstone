#pragma once

// The frontend's implementation of the engine's user-interface callbacks
// (EngineUi on the Rust side). The bridge's run_* operations take one of
// these; the engine calls back through it for logs, progress, and questions.
//
// Methods are invoked on the WORKER thread running the operation. A GUI
// implementation marshals to the main thread and, for questions, blocks the
// worker until the user answers.

#include <cstdint>

#include "rust/cxx.h"

namespace loadstone {

class UiCallbacks {
public:
    virtual ~UiCallbacks() = default;

    virtual void log(rust::Str message) = 0;
    virtual void progress(std::uint32_t percent) = 0;
    virtual bool confirm(rust::Str message) = 0;
    // 0 = retry, 1 = skip, 2 = cancel.
    virtual std::uint8_t retry_skip_cancel(rust::Str message) = 0;
    // Returns the chosen directory, or an empty string for "cancelled".
    // `suggest` may be empty.
    virtual rust::String pick_directory(rust::Str id, rust::Str prompt,
                                        rust::Str suggest) = 0;
    // Puts `text` on the clipboard; false when that failed.
    virtual bool copy_to_clipboard(rust::Str text) = 0;
};

} // namespace loadstone
