Gemini 3.1 Pro is our most advanced reasoning Gemini model,
capable of solving complex problems. Gemini 3.1 Pro can comprehend vast
datasets and challenging problems from different information sources, including
text, audio, images, video, PDFs, and even entire code repositories with its 1M
token context window.

For more information on using the latest Gemini models, see
[Get started with Gemini 3](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/start/get-started-with-gemini-3).

## Quality improvements

Gemini 3.1 Pro includes several quality improvements:

- **Improved SWE and agentic capabilities**: Improved software engineering behavior and usability, with agentic improvements in domains like finance and spreadsheet applications.
- **Improved token efficiency and thinking**: More efficient thinking across various use cases.
- **Expanded thinking levels** : Introduces `MEDIUM` as a `thinking_level` parameter for more options to optimize trade-offs between cost, performance, and speed.

## Custom tools endpoint

For those building with a mix of bash and custom tools, Gemini 3.1 Pro
supports an additional endpoint: `gemini-3.1-pro-preview-customtools`.
This endpoint is better at prioritizing custom tools (such as `view_file` or
`search_code`). As `gemini-3.1-pro-preview-customtools` is optimized for
agentic workflows that use custom tools and bash, you may see quality
fluctuations in some use cases which don't benefit from such tools.

Pricing for `gemini-3.1-pro-preview-customtools` is identical to
Gemini 3.1 Pro. Provisioned Throughput (PT) is
not supported on `gemini-3.1-pro-preview-customtools`.


[Try in Vertex AI](https://console.cloud.google.com/vertex-ai/generative/multimodal/create/text?model=gemini-3.1-pro-preview) [View in Model Garden](https://console.cloud.google.com/vertex-ai/publishers/google/model-garden/gemini-3.1-pro-preview) [(Preview) Deploy example app](https://console.cloud.google.com/vertex-ai/studio/multimodal?suggestedPrompt=How+does+AI+work&deploy=true&model=gemini-3.1-pro-preview)
Note: To use the "Deploy example app" feature, you need a Google Cloud project with billing and Vertex AI API enabled.

| Model ID | `gemini-3.1-pro-preview` ||
| Supported inputs \& outputs | - Inputs: Text, Code, Images, Audio, Video, PDF - Outputs: Text ||
| Token limits | - Maximum input tokens: 1,048,576 - Maximum output tokens: 65,536 ||
| Capabilities | - Supported - [Grounding with Google Search](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/grounding/grounding-with-google-search) - [Code execution](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/code-execution) - [System instructions](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/prompts/system-instruction-introduction) - [Structured output](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/control-generated-output) - [Function calling](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/function-calling) - [Count Tokens](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/get-token-count) - [Thinking](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thinking) - [Implicit context caching](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/context-cache/context-cache-overview) - [Explicit context caching](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/context-cache/context-cache-overview) - [Vertex AI RAG Engine](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/rag-engine/rag-overview) - [Chat completions](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/migrate/openai/overview) - Not supported - [Gemini Live API](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/live-api) - [Content Credentials (C2PA)](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/content-credentials) ||
| Consumption options | - Supported - [Provisioned Throughput](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/provisioned-throughput) - [Standard PayGo](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/standard-paygo) - [Flex PayGo](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/flex-paygo) - [Priority PayGo](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/priority-paygo) - [Batch prediction](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini) - Not supported ||
| Consumption options |
|---|---|---|
| See [Consumption options](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/deploy/consumption-options) for more information. ||
| **Images** | - Maximum images per prompt: 3000 - Maximum file size per file for inline data or direct uploads through the console: 7 MB - Maximum file size per file from Google Cloud Storage: 30 MB - Default resolution tokens: 1120 - Supported MIME types: `image/png`, `image/jpeg`, `image/webp`, `image/heic`, `image/heif` |
| **Documents** | - Maximum number of files per prompt: 3000 - Maximum number of pages per file: 3000 - Maximum file size per file for the API or Cloud Storage imports: 50 MB(application/pdf) or 7 MB(text/plain) - Maximum file size per file for direct uploads through the console: 7 MB - Default resolution tokens: 560 - OCR for scanned PDFs: Not used by default - Supported MIME types: `application/pdf`, `text/plain` |
| **Video** | - Maximum video length (with audio): Approximately 45 minutes - Maximum video length (without audio): Approximately 1 hour - Maximum number of videos per prompt: 10 - Default resolution tokens per frame: 70 - Supported MIME types: `video/x-flv`, `video/quicktime`, `video/mpeg`, `video/mpegs`, `video/mpg`, `video/mp4`, `video/webm`, `video/wmv`, `video/3gpp` |
| **Audio** | - Maximum audio length per prompt: Approximately 8.4 hours, or up to 1 million tokens - Maximum number of audio files per prompt: 1 - Speech understanding for: Audio summarization, transcription, and translation - Supported MIME types: `audio/x-aac`, `audio/flac`, `audio/mp3`, `audio/m4a`, `audio/mpeg`, `audio/mpga`, `audio/mp4`, `audio/ogg`, `audio/pcm`, `audio/wav`, `audio/webm` |
| **Parameter defaults** | - Temperature: 0.0-2.0 (default 1.0) - topP: 0.0-1.0 (default 0.95) - topK: 64 (fixed) - candidateCount: 1--8 (default 1) |
| Model availability | - Global - global |
| See [Deployments and endpoints](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/locations) for more information. ||

^\*^ Provisioned Throughput (PT) is not supported for this endpoint.

<br />