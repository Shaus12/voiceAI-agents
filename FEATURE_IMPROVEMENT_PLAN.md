# Feature Improvement Plan

## 🎯 Overview

This document outlines the planned improvements to the current voiceFX AI project before SaaS conversion. Focus areas: UI improvements, feature cleanup, knowledge base integration, and call summarization.

---

## 📋 Planned Changes

### 1. UI/UX Redesign
**Priority: High**

**Goals:**
- Modern, clean interface
- Better user experience
- Improved workflow builder
- Mobile-responsive design

**Tasks:**
- [ ] Audit current UI components
- [ ] Design new UI mockups
- [ ] Update color scheme and typography
- [ ] Improve navigation structure
- [ ] Redesign workflow builder interface
- [ ] Update dashboard layout
- [ ] Improve mobile responsiveness

**Files to Modify:**
- `ui/src/components/` - Component updates
- `ui/src/app/` - Page layouts
- `ui/src/app/globals.css` - Styling updates

---

### 2. Remove Irrelevant Functions
**Priority: Medium**

**Goals:**
- Clean up unused features
- Simplify codebase
- Improve maintainability
- Reduce confusion for users

**Features to Review for Removal:**

#### Potential Removals:
1. **LoopTalk Testing** (if not actively used)
   - Files: `api/routes/looptalk.py`, `api/services/looptalk/`
   - UI: `ui/src/app/looptalk/`
   - **Decision needed**: Keep for future or remove?

2. **Campaign Features** (if not core feature)
   - Files: `api/routes/campaign.py`, `api/services/campaign/`
   - UI: Campaign management pages
   - **Decision needed**: Core feature or remove?

3. **Reports** (if basic analytics suffice)
   - Files: `api/routes/reports.py`, `api/services/reports/`
   - **Decision needed**: Keep or simplify?

4. **Integrations** (if not used)
   - Files: `api/routes/integration.py`, `api/services/integrations/`
   - **Decision needed**: Keep for future or remove?

5. **Superuser Routes** (if not needed)
   - Files: `api/routes/superuser.py`
   - **Decision needed**: Keep for admin or remove?

**Process:**
1. [ ] Audit all features and routes
2. [ ] Identify unused/irrelevant features
3. [ ] Discuss with partner - get approval
4. [ ] Create cleanup branches
5. [ ] Remove code and dependencies
6. [ ] Update documentation
7. [ ] Test to ensure nothing breaks

**Files to Review:**
- `api/routes/` - All route files
- `api/services/` - All service directories
- `ui/src/app/` - All page directories
- `ui/src/components/` - Component usage

---

### 3. Knowledge Base for Agent
**Priority: High**

**Goal:** Allow users to upload documents/knowledge base that the AI agent can reference during calls.

**Features:**
- Upload documents (PDF, TXT, DOCX)
- Process and chunk documents
- Store embeddings in vector database
- Agent can query knowledge base during calls
- Manage knowledge bases per workflow/organization

**Implementation Plan:**

#### Backend (API)

**New Files:**
- `api/services/knowledge_base/`
  - `__init__.py`
  - `document_processor.py` - Process uploaded documents
  - `embedding_service.py` - Generate embeddings
  - `vector_store.py` - Vector database operations
  - `query_service.py` - Query knowledge base
- `api/routes/knowledge_base.py` - API endpoints
- `api/db/knowledge_base_client.py` - Database operations

**New Database Tables:**
```sql
CREATE TABLE knowledge_bases (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    workflow_id INTEGER REFERENCES workflows(id), -- Optional: per-workflow KB
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE knowledge_base_documents (
    id SERIAL PRIMARY KEY,
    knowledge_base_id INTEGER REFERENCES knowledge_bases(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL, -- Storage path
    file_type TEXT, -- pdf, txt, docx
    file_size INTEGER,
    chunk_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'processing', -- processing, ready, error
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE knowledge_base_chunks (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES knowledge_base_documents(id) ON DELETE CASCADE,
    chunk_index INTEGER,
    content TEXT NOT NULL,
    embedding VECTOR(1536), -- OpenAI embedding dimension
    metadata JSONB, -- page number, section, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for vector similarity search
CREATE INDEX ON knowledge_base_chunks USING ivfflat (embedding vector_cosine_ops);
```

**API Endpoints:**
```
POST   /api/v1/knowledge-bases              - Create knowledge base
GET    /api/v1/knowledge-bases               - List knowledge bases
GET    /api/v1/knowledge-bases/{id}          - Get knowledge base
PUT    /api/v1/knowledge-bases/{id}          - Update knowledge base
DELETE /api/v1/knowledge-bases/{id}          - Delete knowledge base

POST   /api/v1/knowledge-bases/{id}/documents - Upload document
GET    /api/v1/knowledge-bases/{id}/documents  - List documents
DELETE /api/v1/knowledge-bases/{id}/documents/{doc_id} - Delete document

POST   /api/v1/knowledge-bases/{id}/query     - Query knowledge base (for agent)
```

**Integration with Workflow:**
- Add knowledge base selection to workflow configuration
- Modify `PipecatEngine` to query knowledge base when needed
- Add RAG (Retrieval Augmented Generation) to LLM context

#### Frontend (UI)

**New Files:**
- `ui/src/app/knowledge-base/` - Knowledge base pages
  - `page.tsx` - List knowledge bases
  - `[id]/page.tsx` - Knowledge base detail
  - `[id]/upload/page.tsx` - Upload documents
- `ui/src/components/knowledge-base/`
  - `KnowledgeBaseCard.tsx` - KB card component
  - `DocumentUpload.tsx` - File upload component
  - `DocumentList.tsx` - List of documents
  - `KnowledgeBaseSelector.tsx` - Select KB in workflow

**UI Features:**
- Knowledge base management page
- Document upload interface (drag & drop)
- Document processing status
- Link knowledge base to workflow
- Query preview/testing

**Dependencies to Add:**
- Backend: `openai` (for embeddings), `pgvector` (for vector search), `pypdf`, `python-docx`
- Frontend: `react-dropzone` (for file uploads)

**Tasks:**
- [ ] Design knowledge base UI mockups
- [ ] Create database schema
- [ ] Implement document upload endpoint
- [ ] Implement document processing (chunking)
- [ ] Implement embedding generation
- [ ] Set up vector database (pgvector or Pinecone)
- [ ] Implement query/search functionality
- [ ] Integrate with workflow engine
- [ ] Build frontend components
- [ ] Add to workflow configuration UI
- [ ] Test end-to-end

---

### 4. Call Summarization
**Priority: High**

**Goal:** Automatically generate summaries of completed calls with key points, action items, and insights.

**Features:**
- Automatic summarization after call ends
- Key points extraction
- Action items identification
- Sentiment analysis
- Customizable summary templates
- Export summaries (PDF, email)

**Implementation Plan:**

#### Backend (API)

**New Files:**
- `api/services/summarization/`
  - `__init__.py`
  - `call_summarizer.py` - Main summarization logic
  - `prompt_templates.py` - Summary templates
  - `action_item_extractor.py` - Extract action items
  - `sentiment_analyzer.py` - Sentiment analysis
- `api/routes/summarization.py` - API endpoints
- `api/db/summarization_client.py` - Database operations

**New Database Table:**
```sql
CREATE TABLE call_summaries (
    id SERIAL PRIMARY KEY,
    workflow_run_id INTEGER REFERENCES workflow_runs(id) ON DELETE CASCADE,
    summary_text TEXT NOT NULL,
    key_points JSONB, -- Array of key points
    action_items JSONB, -- Array of action items
    sentiment TEXT, -- positive, neutral, negative
    sentiment_score FLOAT, -- 0.0 to 1.0
    duration_seconds INTEGER,
    word_count INTEGER,
    template_used TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX ON call_summaries(workflow_run_id);
```

**API Endpoints:**
```
GET    /api/v1/workflow-runs/{run_id}/summary     - Get call summary
POST   /api/v1/workflow-runs/{run_id}/summarize   - Generate summary (if not exists)
PUT    /api/v1/workflow-runs/{run_id}/summary     - Update summary
GET    /api/v1/workflows/{id}/summaries           - Get all summaries for workflow
POST   /api/v1/summaries/export                   - Export summary (PDF/email)
```

**Integration Points:**
- Trigger summarization when `workflow_run.is_completed = True`
- Use transcript from workflow run
- Store summary linked to workflow run
- Make available in workflow run details

**Summarization Process:**
1. Wait for call to complete
2. Retrieve transcript
3. Generate summary using LLM (with structured output)
4. Extract key points
5. Identify action items
6. Analyze sentiment
7. Store in database
8. Optionally send email notification

#### Frontend (UI)

**New Files:**
- `ui/src/components/summarization/`
  - `CallSummary.tsx` - Display summary component
  - `KeyPointsList.tsx` - Key points display
  - `ActionItemsList.tsx` - Action items display
  - `SentimentBadge.tsx` - Sentiment indicator
  - `SummaryExport.tsx` - Export options

**UI Integration:**
- Add summary tab to workflow run details page
- Show summary preview in workflow runs list
- Add "View Summary" button
- Export options (PDF, email, copy)

**Tasks:**
- [ ] Design summary UI mockups
- [ ] Create database schema
- [ ] Implement summarization service
- [ ] Create summary templates
- [ ] Implement action item extraction
- [ ] Implement sentiment analysis
- [ ] Add auto-summarization trigger
- [ ] Build frontend components
- [ ] Add to workflow run details page
- [ ] Add export functionality
- [ ] Test with various call types

---

## 📅 Implementation Timeline

### Phase 1: Foundation & Cleanup (Week 1-2)
- [ ] Audit and remove irrelevant features
- [ ] Set up collaboration workflow
- [ ] Create feature branches

### Phase 2: Knowledge Base (Week 3-5)
- [ ] Backend implementation
- [ ] Vector database setup
- [ ] Frontend implementation
- [ ] Integration with workflows

### Phase 3: Call Summarization (Week 6-7)
- [ ] Backend implementation
- [ ] Frontend implementation
- [ ] Testing and refinement

### Phase 4: UI Redesign (Week 8-10)
- [ ] Design mockups
- [ ] Component updates
- [ ] Layout improvements
- [ ] Mobile responsiveness

### Phase 5: Testing & Polish (Week 11-12)
- [ ] End-to-end testing
- [ ] Bug fixes
- [ ] Documentation
- [ ] Performance optimization

---

## 🗂️ File Organization

### New Directory Structure

```
api/
  ├── services/
  │   ├── knowledge_base/        # NEW
  │   │   ├── __init__.py
  │   │   ├── document_processor.py
  │   │   ├── embedding_service.py
  │   │   ├── vector_store.py
  │   │   └── query_service.py
  │   └── summarization/          # NEW
  │       ├── __init__.py
  │       ├── call_summarizer.py
  │       ├── prompt_templates.py
  │       ├── action_item_extractor.py
  │       └── sentiment_analyzer.py
  ├── routes/
  │   ├── knowledge_base.py       # NEW
  │   └── summarization.py        # NEW
  └── db/
      ├── knowledge_base_client.py # NEW
      └── summarization_client.py  # NEW

ui/
  ├── src/
  │   ├── app/
  │   │   ├── knowledge-base/     # NEW
  │   │   │   ├── page.tsx
  │   │   │   └── [id]/
  │   │   └── workflow/
  │   │       └── [workflowId]/
  │   │           └── runs/
  │   │               └── [runId]/
  │   │                   └── summary/  # NEW
  │   └── components/
  │       ├── knowledge-base/     # NEW
  │       │   ├── KnowledgeBaseCard.tsx
  │       │   ├── DocumentUpload.tsx
  │       │   └── ...
  │       └── summarization/      # NEW
  │           ├── CallSummary.tsx
  │           └── ...
```

---

## 🔧 Technical Decisions Needed

### Knowledge Base
1. **Vector Database Choice:**
   - Option A: pgvector (PostgreSQL extension) - Simple, integrated
   - Option B: Pinecone - Managed, scalable
   - **Recommendation**: Start with pgvector, migrate to Pinecone if needed

2. **Embedding Model:**
   - OpenAI `text-embedding-3-small` (recommended)
   - OpenAI `text-embedding-3-large` (better quality, more expensive)
   - **Recommendation**: Start with `small`, upgrade if needed

3. **Chunking Strategy:**
   - Fixed size chunks (500 tokens)
   - Semantic chunking (by paragraphs/sections)
   - **Recommendation**: Start with fixed size, add semantic later

### Call Summarization
1. **LLM for Summarization:**
   - Use same LLM as workflow (consistent)
   - Use specialized model (GPT-4 for better quality)
   - **Recommendation**: Use workflow LLM, allow override

2. **When to Summarize:**
   - Immediately after call ends (async)
   - On-demand (user requests)
   - **Recommendation**: Both - auto-summarize, allow manual trigger

3. **Summary Storage:**
   - Store in database (current plan)
   - Store in vector DB for searchability
   - **Recommendation**: Database for now, add vector search later

---

## 📝 Next Steps

1. **Review this plan with partner**
2. **Decide on feature removals** (get consensus)
3. **Set up collaboration workflow** (GitHub Projects, branches)
4. **Create GitHub issues** for each feature
5. **Start with Phase 1** (cleanup)

---

## ✅ Definition of Done (Per Feature)

- [ ] Backend implementation complete
- [ ] Frontend implementation complete
- [ ] Database migrations created
- [ ] API endpoints tested
- [ ] UI tested manually
- [ ] Integration tested
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Merged to develop

---

*Last Updated: [Date]*
*Version: 1.0*

